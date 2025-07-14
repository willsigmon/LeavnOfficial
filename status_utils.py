#!/usr/bin/env python3
"""
Status Checking and Reporting Utilities for TestFlight Invitations

This module provides comprehensive status checking and reporting features for:
- TestFlight build processing status monitoring
- Invitation status tracking and verification
- Progress indicators with color-coded output
- Summary report generation

Features:
- Real-time build status monitoring with retry logic
- Invitation status checking with detailed results
- Progress bars showing X/50 emails processed
- Color-coded terminal output for success/failure/warning states
- Comprehensive reporting with statistics and summaries
- Export capabilities for reports

Author: Leavn Development Team
Version: 1.0.0
"""

import os
import time
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Any, Union
from dataclasses import dataclass, asdict
from pathlib import Path
import threading
from enum import Enum

# Color codes for terminal output
class Colors:
    """ANSI color codes for terminal output"""
    RESET = '\033[0m'
    BOLD = '\033[1m'
    
    # Standard colors
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    
    # Bright colors
    BRIGHT_RED = '\033[91m'
    BRIGHT_GREEN = '\033[92m'
    BRIGHT_YELLOW = '\033[93m'
    BRIGHT_BLUE = '\033[94m'
    BRIGHT_MAGENTA = '\033[95m'
    BRIGHT_CYAN = '\033[96m'
    BRIGHT_WHITE = '\033[97m'
    
    # Background colors
    BG_RED = '\033[41m'
    BG_GREEN = '\033[42m'
    BG_YELLOW = '\033[43m'
    BG_BLUE = '\033[44m'

class StatusType(Enum):
    """Status types for color coding"""
    SUCCESS = "success"
    WARNING = "warning"
    ERROR = "error"
    INFO = "info"
    PROCESSING = "processing"

@dataclass
class BuildStatus:
    """Build status information"""
    build_id: str
    version: str
    build_number: str
    processing_state: str
    uploaded_date: str
    last_checked: datetime
    processing_time: Optional[timedelta] = None
    is_ready: bool = False
    error_message: Optional[str] = None

@dataclass
class InvitationStatus:
    """Invitation status information"""
    email: str
    tester_id: Optional[str]
    status: str
    invited_date: Optional[datetime]
    last_checked: datetime
    error_message: Optional[str] = None
    build_version: Optional[str] = None
    app_id: Optional[str] = None

@dataclass
class ProcessingProgress:
    """Progress tracking for batch operations"""
    total: int
    processed: int = 0
    successful: int = 0
    failed: int = 0
    warnings: int = 0
    start_time: datetime = None
    
    def __post_init__(self):
        if self.start_time is None:
            self.start_time = datetime.now()
    
    @property
    def percentage(self) -> float:
        """Calculate completion percentage"""
        return (self.processed / self.total * 100) if self.total > 0 else 0
    
    @property
    def elapsed_time(self) -> timedelta:
        """Calculate elapsed time"""
        return datetime.now() - self.start_time
    
    @property
    def estimated_remaining(self) -> Optional[timedelta]:
        """Estimate remaining time"""
        if self.processed == 0:
            return None
        rate = self.processed / self.elapsed_time.total_seconds()
        remaining_items = self.total - self.processed
        return timedelta(seconds=remaining_items / rate)

class ProgressBar:
    """Progress bar with color coding"""
    
    def __init__(self, total: int, width: int = 50, show_eta: bool = True):
        self.total = total
        self.width = width
        self.show_eta = show_eta
        self.progress = ProcessingProgress(total)
    
    def update(self, processed: int, successful: int = None, failed: int = None, warnings: int = None):
        """Update progress bar"""
        self.progress.processed = processed
        if successful is not None:
            self.progress.successful = successful
        if failed is not None:
            self.progress.failed = failed
        if warnings is not None:
            self.progress.warnings = warnings
    
    def render(self) -> str:
        """Render progress bar as string"""
        percentage = self.progress.percentage
        filled_width = int(self.width * percentage / 100)
        
        # Create bar with colors
        bar = f"{Colors.GREEN}{'█' * filled_width}{Colors.RESET}"
        bar += f"{Colors.WHITE}{'░' * (self.width - filled_width)}{Colors.RESET}"
        
        # Status text with colors
        status_parts = []
        if self.progress.successful > 0:
            status_parts.append(f"{Colors.GREEN}{self.progress.successful} ✓{Colors.RESET}")
        if self.progress.failed > 0:
            status_parts.append(f"{Colors.RED}{self.progress.failed} ✗{Colors.RESET}")
        if self.progress.warnings > 0:
            status_parts.append(f"{Colors.YELLOW}{self.progress.warnings} ⚠{Colors.RESET}")
        
        status_text = " | ".join(status_parts) if status_parts else ""
        
        # ETA
        eta_text = ""
        if self.show_eta and self.progress.estimated_remaining:
            eta = self.progress.estimated_remaining
            eta_text = f" | ETA: {format_duration(eta)}"
        
        return (f"Progress: [{bar}] {percentage:5.1f}% "
                f"({self.progress.processed}/{self.total}){eta_text}"
                f"{' | ' + status_text if status_text else ''}")
    
    def print_progress(self):
        """Print progress bar to terminal"""
        print(f"\r{self.render()}", end="", flush=True)

def colorize_text(text: str, status_type: StatusType, bold: bool = False) -> str:
    """Apply color formatting to text based on status type"""
    color_map = {
        StatusType.SUCCESS: Colors.GREEN,
        StatusType.WARNING: Colors.YELLOW,
        StatusType.ERROR: Colors.RED,
        StatusType.INFO: Colors.BLUE,
        StatusType.PROCESSING: Colors.CYAN
    }
    
    color = color_map.get(status_type, Colors.RESET)
    formatted = f"{color}{text}{Colors.RESET}"
    
    if bold:
        formatted = f"{Colors.BOLD}{formatted}"
    
    return formatted

def format_duration(duration: timedelta) -> str:
    """Format duration in human-readable format"""
    total_seconds = int(duration.total_seconds())
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    
    if hours > 0:
        return f"{hours}h {minutes}m {seconds}s"
    elif minutes > 0:
        return f"{minutes}m {seconds}s"
    else:
        return f"{seconds}s"

def print_status_message(message: str, status_type: StatusType, prefix: str = ""):
    """Print colored status message"""
    icons = {
        StatusType.SUCCESS: "✅",
        StatusType.WARNING: "⚠️",
        StatusType.ERROR: "❌",
        StatusType.INFO: "ℹ️",
        StatusType.PROCESSING: "🔄"
    }
    
    icon = icons.get(status_type, "")
    colored_message = colorize_text(message, status_type)
    print(f"{prefix}{icon} {colored_message}")

class StatusChecker:
    """Status checking utilities for TestFlight builds and invitations"""
    
    def __init__(self, api_client=None):
        """
        Initialize status checker
        
        Args:
            api_client: AppStoreConnectAPI instance
        """
        from app_store_api import AppStoreConnectAPI, AppStoreConnectAPIError
        
        self.api_client = api_client or AppStoreConnectAPI()
        self.AppStoreConnectAPIError = AppStoreConnectAPIError
        self.logger = logging.getLogger(__name__)
    
    def check_build_status(self, app_id: Optional[str] = None, bundle_id: str = "com.leavn.app",
                          build_id: Optional[str] = None, timeout_minutes: int = 30) -> BuildStatus:
        """
        Verify TestFlight build processing status
        
        Args:
            app_id: App ID (optional, will be retrieved if not provided)
            bundle_id: Bundle identifier for app lookup
            build_id: Specific build ID to check (optional, uses latest if not provided)
            timeout_minutes: Maximum time to wait for processing completion
            
        Returns:
            BuildStatus: Current build status information
            
        Raises:
            AppStoreConnectAPIError: If API request fails
        """
        try:
            print_status_message("Checking build status...", StatusType.PROCESSING)
            
            # Get app ID if not provided
            if not app_id:
                app_id = self.api_client.get_app_id(bundle_id)
            
            # Get build information
            if build_id:
                build_info = self._get_build_by_id(build_id)
            else:
                build_info = self.api_client.get_latest_build(app_id, bundle_id)
            
            # Calculate processing time if available
            uploaded_date = datetime.fromisoformat(build_info['uploaded_date'].replace('Z', '+00:00'))
            processing_time = datetime.now() - uploaded_date.replace(tzinfo=None)
            
            # Determine if build is ready
            is_ready = build_info['processing_state'] in ['PROCESSING_COMPLETE', 'READY_FOR_BETA_TESTING']
            
            status = BuildStatus(
                build_id=build_info['id'],
                version=build_info['version'],
                build_number=build_info['build_number'],
                processing_state=build_info['processing_state'],
                uploaded_date=build_info['uploaded_date'],
                last_checked=datetime.now(),
                processing_time=processing_time,
                is_ready=is_ready
            )
            
            # Print status with appropriate color
            if is_ready:
                print_status_message(
                    f"Build {status.version} ({status.build_number}) is ready for testing",
                    StatusType.SUCCESS
                )
            elif build_info['processing_state'] == 'PROCESSING':
                print_status_message(
                    f"Build {status.version} ({status.build_number}) is still processing "
                    f"(Time: {format_duration(processing_time)})",
                    StatusType.PROCESSING
                )
            else:
                print_status_message(
                    f"Build {status.version} ({status.build_number}) status: {build_info['processing_state']}",
                    StatusType.WARNING
                )
            
            return status
            
        except self.AppStoreConnectAPIError as e:
            error_msg = f"Failed to check build status: {e.message}"
            print_status_message(error_msg, StatusType.ERROR)
            raise
        except Exception as e:
            error_msg = f"Unexpected error checking build status: {str(e)}"
            print_status_message(error_msg, StatusType.ERROR)
            raise self.AppStoreConnectAPIError(error_msg)
    
    def wait_for_build_ready(self, app_id: Optional[str] = None, bundle_id: str = "com.leavn.app",
                           build_id: Optional[str] = None, timeout_minutes: int = 30,
                           check_interval: int = 60) -> BuildStatus:
        """
        Wait for build to be ready for testing
        
        Args:
            app_id: App ID
            bundle_id: Bundle identifier
            build_id: Specific build ID
            timeout_minutes: Maximum time to wait
            check_interval: Check interval in seconds
            
        Returns:
            BuildStatus: Final build status
        """
        print_status_message(f"Waiting for build to be ready (timeout: {timeout_minutes}m)...", StatusType.INFO)
        
        start_time = datetime.now()
        timeout_delta = timedelta(minutes=timeout_minutes)
        
        while datetime.now() - start_time < timeout_delta:
            status = self.check_build_status(app_id, bundle_id, build_id, timeout_minutes)
            
            if status.is_ready:
                print_status_message("Build is ready for testing!", StatusType.SUCCESS)
                return status
            
            remaining_time = timeout_delta - (datetime.now() - start_time)
            print_status_message(
                f"Still processing... Checking again in {check_interval}s "
                f"(Time remaining: {format_duration(remaining_time)})",
                StatusType.INFO
            )
            
            time.sleep(check_interval)
        
        # Timeout reached
        final_status = self.check_build_status(app_id, bundle_id, build_id, timeout_minutes)
        print_status_message(
            f"Timeout reached. Build status: {final_status.processing_state}",
            StatusType.WARNING
        )
        return final_status
    
    def check_invitation_status(self, emails: List[str], app_id: Optional[str] = None,
                              bundle_id: str = "com.leavn.app") -> List[InvitationStatus]:
        """
        Query status of sent invitations
        
        Args:
            emails: List of email addresses to check
            app_id: App ID (optional)
            bundle_id: Bundle identifier
            
        Returns:
            List[InvitationStatus]: Status information for each email
        """
        print_status_message(f"Checking invitation status for {len(emails)} testers...", StatusType.PROCESSING)
        
        if not app_id:
            app_id = self.api_client.get_app_id(bundle_id)
        
        statuses = []
        progress = ProgressBar(len(emails), show_eta=True)
        
        for i, email in enumerate(emails):
            try:
                # Check if tester exists
                tester_info = self._find_tester_by_email(email)
                
                if tester_info:
                    # Check if tester is associated with app
                    app_association = self._check_tester_app_association(tester_info['id'], app_id)
                    
                    status = InvitationStatus(
                        email=email,
                        tester_id=tester_info['id'],
                        status="invited" if app_association else "exists_not_invited",
                        invited_date=None,  # Would need additional API call to get exact date
                        last_checked=datetime.now(),
                        app_id=app_id
                    )
                    
                    progress.update(i + 1, progress.progress.successful + 1)
                else:
                    status = InvitationStatus(
                        email=email,
                        tester_id=None,
                        status="not_invited",
                        invited_date=None,
                        last_checked=datetime.now(),
                        app_id=app_id
                    )
                    
                    progress.update(i + 1, progress.progress.successful, progress.progress.failed + 1)
                
                statuses.append(status)
                
            except Exception as e:
                status = InvitationStatus(
                    email=email,
                    tester_id=None,
                    status="error",
                    invited_date=None,
                    last_checked=datetime.now(),
                    error_message=str(e),
                    app_id=app_id
                )
                statuses.append(status)
                progress.update(i + 1, progress.progress.successful, progress.progress.failed + 1)
            
            progress.print_progress()
            time.sleep(0.1)  # Small delay to avoid rate limiting
        
        print()  # New line after progress bar
        
        # Summary
        invited_count = sum(1 for s in statuses if s.status == "invited")
        not_invited_count = sum(1 for s in statuses if s.status == "not_invited")
        error_count = sum(1 for s in statuses if s.status == "error")
        
        print_status_message(
            f"Invitation status check complete: {invited_count} invited, "
            f"{not_invited_count} not invited, {error_count} errors",
            StatusType.INFO
        )
        
        return statuses
    
    def _get_build_by_id(self, build_id: str) -> Dict:
        """Get build information by ID"""
        try:
            response = self.api_client._make_request('GET', f'/builds/{build_id}')
            return {
                'id': response['data']['id'],
                'version': response['data']['attributes']['version'],
                'build_number': response['data']['attributes']['buildNumber'],
                'processing_state': response['data']['attributes']['processingState'],
                'uploaded_date': response['data']['attributes']['uploadedDate']
            }
        except Exception as e:
            raise self.AppStoreConnectAPIError(f"Failed to get build {build_id}: {str(e)}")
    
    def _find_tester_by_email(self, email: str) -> Optional[Dict]:
        """Find tester by email address"""
        try:
            params = {
                'filter[email]': email,
                'fields[betaTesters]': 'email,firstName,lastName'
            }
            
            response = self.api_client._make_request('GET', '/betaTesters', params=params)
            
            if response.get('data'):
                return response['data'][0]
            return None
            
        except Exception:
            return None
    
    def _check_tester_app_association(self, tester_id: str, app_id: str) -> bool:
        """Check if tester is associated with app"""
        try:
            params = {
                'fields[apps]': 'bundleId'
            }
            
            response = self.api_client._make_request(
                'GET', 
                f'/betaTesters/{tester_id}/apps',
                params=params
            )
            
            app_ids = [app['id'] for app in response.get('data', [])]
            return app_id in app_ids
            
        except Exception:
            return False

class ReportGenerator:
    """Generate comprehensive reports for invitation processes"""
    
    def __init__(self, output_dir: str = "./reports"):
        """
        Initialize report generator
        
        Args:
            output_dir: Directory to save reports
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    
    def generate_report(self, build_status: Optional[BuildStatus] = None,
                       invitation_statuses: Optional[List[InvitationStatus]] = None,
                       additional_data: Optional[Dict] = None) -> Dict:
        """
        Create a summary report of the invitation process
        
        Args:
            build_status: Build status information
            invitation_statuses: List of invitation statuses
            additional_data: Additional data to include in report
            
        Returns:
            Dict: Comprehensive report data
        """
        print_status_message("Generating invitation process report...", StatusType.PROCESSING)
        
        report = {
            'report_metadata': {
                'generated_at': datetime.now().isoformat(),
                'report_version': '1.0.0',
                'generated_by': 'TestFlight Status Utils'
            },
            'build_information': None,
            'invitation_summary': None,
            'detailed_results': None,
            'statistics': {},
            'recommendations': []
        }
        
        # Build information
        if build_status:
            report['build_information'] = {
                'build_id': build_status.build_id,
                'version': build_status.version,
                'build_number': build_status.build_number,
                'processing_state': build_status.processing_state,
                'uploaded_date': build_status.uploaded_date,
                'processing_time': format_duration(build_status.processing_time) if build_status.processing_time else None,
                'is_ready': build_status.is_ready,
                'last_checked': build_status.last_checked.isoformat(),
                'error_message': build_status.error_message
            }
        
        # Invitation summary and details
        if invitation_statuses:
            invited = [s for s in invitation_statuses if s.status == "invited"]
            not_invited = [s for s in invitation_statuses if s.status == "not_invited"]
            errors = [s for s in invitation_statuses if s.status == "error"]
            exists_not_invited = [s for s in invitation_statuses if s.status == "exists_not_invited"]
            
            report['invitation_summary'] = {
                'total_checked': len(invitation_statuses),
                'successfully_invited': len(invited),
                'not_invited': len(not_invited),
                'exists_but_not_invited': len(exists_not_invited),
                'errors': len(errors),
                'success_rate': (len(invited) / len(invitation_statuses) * 100) if invitation_statuses else 0
            }
            
            report['detailed_results'] = {
                'invited_testers': [
                    {
                        'email': s.email,
                        'tester_id': s.tester_id,
                        'last_checked': s.last_checked.isoformat()
                    }
                    for s in invited
                ],
                'not_invited_testers': [
                    {
                        'email': s.email,
                        'last_checked': s.last_checked.isoformat()
                    }
                    for s in not_invited
                ],
                'error_testers': [
                    {
                        'email': s.email,
                        'error_message': s.error_message,
                        'last_checked': s.last_checked.isoformat()
                    }
                    for s in errors
                ],
                'exists_not_invited_testers': [
                    {
                        'email': s.email,
                        'tester_id': s.tester_id,
                        'last_checked': s.last_checked.isoformat()
                    }
                    for s in exists_not_invited
                ]
            }
            
            # Statistics
            report['statistics'] = {
                'invitation_success_rate': f"{len(invited) / len(invitation_statuses) * 100:.1f}%",
                'error_rate': f"{len(errors) / len(invitation_statuses) * 100:.1f}%",
                'total_existing_testers': len(invited) + len(exists_not_invited),
                'new_testers_needed': len(not_invited)
            }
            
            # Recommendations
            if errors:
                report['recommendations'].append(
                    f"Review {len(errors)} failed invitations and retry if necessary"
                )
            
            if exists_not_invited:
                report['recommendations'].append(
                    f"Add {len(exists_not_invited)} existing testers to the app"
                )
            
            if not_invited:
                report['recommendations'].append(
                    f"Send invitations to {len(not_invited)} new testers"
                )
        
        # Include additional data
        if additional_data:
            report['additional_data'] = additional_data
        
        # Print summary
        self._print_report_summary(report)
        
        print_status_message("Report generation complete", StatusType.SUCCESS)
        return report
    
    def save_report(self, report: Dict, filename: Optional[str] = None, 
                   format: str = 'json') -> str:
        """
        Save report to file
        
        Args:
            report: Report data
            filename: Output filename (auto-generated if not provided)
            format: Report format ('json', 'txt')
            
        Returns:
            str: Path to saved report file
        """
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"testflight_report_{timestamp}.{format}"
        
        filepath = self.output_dir / filename
        
        if format == 'json':
            with open(filepath, 'w') as f:
                json.dump(report, f, indent=2, default=str)
        elif format == 'txt':
            with open(filepath, 'w') as f:
                self._write_text_report(report, f)
        else:
            raise ValueError(f"Unsupported format: {format}")
        
        print_status_message(f"Report saved to {filepath}", StatusType.SUCCESS)
        return str(filepath)
    
    def _print_report_summary(self, report: Dict):
        """Print report summary to console"""
        print("\n" + "=" * 60)
        print_status_message("📊 TESTFLIGHT INVITATION REPORT SUMMARY", StatusType.INFO, "")
        print("=" * 60)
        
        # Build information
        if report.get('build_information'):
            build = report['build_information']
            print(f"\n📱 Build Information:")
            print(f"   Version: {build['version']} ({build['build_number']})")
            print(f"   Status: {colorize_text(build['processing_state'], StatusType.INFO)}")
            print(f"   Ready: {colorize_text(str(build['is_ready']), StatusType.SUCCESS if build['is_ready'] else StatusType.WARNING)}")
            if build['processing_time']:
                print(f"   Processing Time: {build['processing_time']}")
        
        # Invitation summary
        if report.get('invitation_summary'):
            summary = report['invitation_summary']
            print(f"\n📧 Invitation Summary:")
            print(f"   Total Checked: {summary['total_checked']}")
            print(f"   Successfully Invited: {colorize_text(str(summary['successfully_invited']), StatusType.SUCCESS)}")
            print(f"   Not Invited: {colorize_text(str(summary['not_invited']), StatusType.WARNING)}")
            print(f"   Errors: {colorize_text(str(summary['errors']), StatusType.ERROR if summary['errors'] > 0 else StatusType.SUCCESS)}")
            success_rate_text = f"{summary['success_rate']:.1f}%"
            success_rate_status = StatusType.SUCCESS if summary['success_rate'] > 90 else StatusType.WARNING
            print(f"   Success Rate: {colorize_text(success_rate_text, success_rate_status)}")
        
        # Recommendations
        if report.get('recommendations'):
            print(f"\n💡 Recommendations:")
            for rec in report['recommendations']:
                print(f"   • {rec}")
        
        print("\n" + "=" * 60)
    
    def _write_text_report(self, report: Dict, file):
        """Write report in text format"""
        file.write("TESTFLIGHT INVITATION REPORT\n")
        file.write("=" * 50 + "\n\n")
        
        file.write(f"Generated: {report['report_metadata']['generated_at']}\n")
        file.write(f"Version: {report['report_metadata']['report_version']}\n\n")
        
        if report.get('build_information'):
            build = report['build_information']
            file.write("BUILD INFORMATION\n")
            file.write("-" * 20 + "\n")
            file.write(f"Version: {build['version']} ({build['build_number']})\n")
            file.write(f"Status: {build['processing_state']}\n")
            file.write(f"Ready: {build['is_ready']}\n")
            if build['processing_time']:
                file.write(f"Processing Time: {build['processing_time']}\n")
            file.write("\n")
        
        if report.get('invitation_summary'):
            summary = report['invitation_summary']
            file.write("INVITATION SUMMARY\n")
            file.write("-" * 20 + "\n")
            file.write(f"Total Checked: {summary['total_checked']}\n")
            file.write(f"Successfully Invited: {summary['successfully_invited']}\n")
            file.write(f"Not Invited: {summary['not_invited']}\n")
            file.write(f"Errors: {summary['errors']}\n")
            file.write(f"Success Rate: {summary['success_rate']:.1f}%\n\n")
        
        if report.get('recommendations'):
            file.write("RECOMMENDATIONS\n")
            file.write("-" * 20 + "\n")
            for rec in report['recommendations']:
                file.write(f"• {rec}\n")

# Convenience functions for direct usage
def check_build_status(app_id: Optional[str] = None, bundle_id: str = "com.leavn.app",
                      build_id: Optional[str] = None) -> BuildStatus:
    """
    Convenience function to check build status
    
    Args:
        app_id: App ID
        bundle_id: Bundle identifier
        build_id: Specific build ID
        
    Returns:
        BuildStatus: Build status information
    """
    checker = StatusChecker()
    return checker.check_build_status(app_id, bundle_id, build_id)

def check_invitation_status(emails: List[str], app_id: Optional[str] = None,
                           bundle_id: str = "com.leavn.app") -> List[InvitationStatus]:
    """
    Convenience function to check invitation status
    
    Args:
        emails: List of email addresses
        app_id: App ID
        bundle_id: Bundle identifier
        
    Returns:
        List[InvitationStatus]: Status information for each email
    """
    checker = StatusChecker()
    return checker.check_invitation_status(emails, app_id, bundle_id)

def generate_report(build_status: Optional[BuildStatus] = None,
                   invitation_statuses: Optional[List[InvitationStatus]] = None,
                   save_to_file: bool = True, output_dir: str = "./reports") -> Dict:
    """
    Convenience function to generate report
    
    Args:
        build_status: Build status information
        invitation_statuses: Invitation statuses
        save_to_file: Whether to save report to file
        output_dir: Output directory for reports
        
    Returns:
        Dict: Report data
    """
    generator = ReportGenerator(output_dir)
    report = generator.generate_report(build_status, invitation_statuses)
    
    if save_to_file:
        generator.save_report(report)
    
    return report

# Example usage and testing
def main():
    """Example usage of status checking utilities"""
    try:
        print_status_message("TestFlight Status Utilities Demo", StatusType.INFO)
        print("=" * 60)
        
        # Initialize status checker
        checker = StatusChecker()
        
        # 1. Check build status
        print_status_message("1. Checking build status...", StatusType.INFO)
        build_status = checker.check_build_status()
        
        # 2. Check invitation status for example emails
        example_emails = ["test1@example.com", "test2@example.com", "test3@example.com"]
        print_status_message(f"2. Checking invitation status for {len(example_emails)} emails...", StatusType.INFO)
        invitation_statuses = checker.check_invitation_status(example_emails)
        
        # 3. Generate comprehensive report
        print_status_message("3. Generating comprehensive report...", StatusType.INFO)
        generator = ReportGenerator()
        report = generator.generate_report(build_status, invitation_statuses)
        
        # 4. Save report
        report_path = generator.save_report(report)
        print_status_message(f"Report saved to: {report_path}", StatusType.SUCCESS)
        
        print_status_message("Demo completed successfully!", StatusType.SUCCESS)
        
    except Exception as e:
        print_status_message(f"Demo failed: {str(e)}", StatusType.ERROR)
        raise

if __name__ == "__main__":
    main()
