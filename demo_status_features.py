#!/usr/bin/env python3
"""
Quick Demo of Status Checking and Reporting Features

This script demonstrates the key features of the status utilities including:
- Color-coded progress indicators  
- Progress bars showing X/50 emails processed
- Report generation with statistics
- Status checking workflow simulation

This demo runs without requiring API credentials by using mock data.

Author: Leavn Development Team
Version: 1.0.0
"""

import time
from datetime import datetime, timedelta
from status_utils import (
    ProgressBar, ReportGenerator, StatusType, BuildStatus, InvitationStatus,
    print_status_message, colorize_text, format_duration
)

def demo_progress_indicators():
    """Demonstrate progress indicators showing X/50 emails processed"""
    print_status_message("📧 Simulating TestFlight invitation process...", StatusType.PROCESSING)
    
    total_emails = 50
    progress = ProgressBar(total_emails, width=50, show_eta=True)
    
    successful = 0
    failed = 0
    warnings = 0
    
    print(f"\nProcessing {total_emails} TestFlight invitations:")
    
    for i in range(total_emails + 1):
        if i > 0:
            # Simulate processing outcomes (85% success, 10% warning, 5% failure)
            outcome = i % 20
            if outcome < 17:  # 85% success rate
                successful += 1
            elif outcome < 19:  # 10% warning rate (existing users)
                warnings += 1
            else:  # 5% failure rate
                failed += 1
        
        progress.update(i, successful, failed, warnings)
        progress.print_progress()
        
        # Simulate processing time
        time.sleep(0.1)
    
    print("\n")
    print_status_message(
        f"Invitation batch complete: {successful} invited, {warnings} existing, {failed} failed",
        StatusType.SUCCESS
    )
    
    return {'successful': successful, 'warnings': warnings, 'failed': failed}

def demo_color_coded_output():
    """Demonstrate color-coded output for different status types"""
    print_status_message("🎨 Demonstrating color-coded status output...", StatusType.INFO)
    
    # Simulate various status scenarios
    scenarios = [
        ("Build processing started", StatusType.PROCESSING),
        ("Build validation completed", StatusType.SUCCESS),
        ("Some testers already exist", StatusType.WARNING),
        ("Network timeout occurred", StatusType.ERROR),
        ("Checking invitation status", StatusType.INFO),
        ("All invitations sent successfully", StatusType.SUCCESS)
    ]
    
    for message, status_type in scenarios:
        print_status_message(message, status_type)
        time.sleep(0.5)
    
    print(f"\nColorized text examples:")
    print(f"✅ {colorize_text('42 invitations sent successfully', StatusType.SUCCESS)}")
    print(f"⚠️  {colorize_text('8 users were already invited', StatusType.WARNING)}")
    print(f"❌ {colorize_text('2 invitations failed due to invalid emails', StatusType.ERROR)}")

def create_mock_data():
    """Create mock data for demonstration"""
    # Mock build status
    build_status = BuildStatus(
        build_id="build_abc123",
        version="2.1.0",
        build_number="156",
        processing_state="PROCESSING_COMPLETE",
        uploaded_date=(datetime.now() - timedelta(hours=2)).isoformat(),
        last_checked=datetime.now(),
        processing_time=timedelta(minutes=45),
        is_ready=True
    )
    
    # Mock invitation statuses
    test_emails = [
        "alice@company.com", "bob@startup.io", "charlie@tech.org",
        "diana@mobile.dev", "eve@design.studio", "frank@beta.test",
        "grace@product.team", "henry@ux.agency", "iris@code.dev",
        "jack@test.user", "kelly@quality.qa", "liam@feedback.com"
    ]
    
    invitation_statuses = []
    for i, email in enumerate(test_emails):
        if i % 4 == 0:
            status = "invited"
            tester_id = f"tester_{i:03d}"
        elif i % 4 == 1:
            status = "not_invited"
            tester_id = None
        elif i % 4 == 2:
            status = "exists_not_invited"
            tester_id = f"existing_{i:03d}"
        else:
            status = "error"
            tester_id = None
        
        invitation_statuses.append(InvitationStatus(
            email=email,
            tester_id=tester_id,
            status=status,
            invited_date=datetime.now() - timedelta(hours=1) if status == "invited" else None,
            last_checked=datetime.now(),
            error_message="Invalid email format" if status == "error" else None,
            app_id="app_xyz789"
        ))
    
    return build_status, invitation_statuses

def demo_report_generation():
    """Demonstrate comprehensive report generation"""
    print_status_message("📊 Generating comprehensive TestFlight report...", StatusType.PROCESSING)
    
    # Create mock data
    build_status, invitation_statuses = create_mock_data()
    
    # Generate report
    generator = ReportGenerator("./demo_reports")
    
    additional_data = {
        "campaign_name": "Beta Release 2.1.0",
        "target_testers": 50,
        "campaign_start": datetime.now().isoformat(),
        "notes": "First beta release with new dashboard features"
    }
    
    report = generator.generate_report(
        build_status=build_status,
        invitation_statuses=invitation_statuses,
        additional_data=additional_data
    )
    
    # Save report in multiple formats
    json_path = generator.save_report(report, "demo_report.json", "json")
    txt_path = generator.save_report(report, "demo_report.txt", "txt")
    
    print_status_message(f"Reports saved: {json_path}, {txt_path}", StatusType.SUCCESS)
    
    return report

def demo_build_status_monitoring():
    """Simulate build status monitoring"""
    print_status_message("🏗️ Simulating build status monitoring...", StatusType.INFO)
    
    # Simulate different build states
    states = [
        ("UPLOADING", "Build upload in progress", StatusType.PROCESSING),
        ("PROCESSING", "Apple is processing the build", StatusType.PROCESSING),
        ("PROCESSING", "Still processing (this can take a while)", StatusType.PROCESSING),
        ("PROCESSING_COMPLETE", "Build processing completed", StatusType.SUCCESS),
        ("READY_FOR_BETA_TESTING", "Build ready for TestFlight distribution", StatusType.SUCCESS)
    ]
    
    print("\nBuild Status Timeline:")
    for i, (state, message, status_type) in enumerate(states):
        timestamp = datetime.now() + timedelta(minutes=i*15)
        time_str = timestamp.strftime("%H:%M:%S")
        
        print(f"[{time_str}] ", end="")
        print_status_message(f"{state}: {message}", status_type, "")
        
        if i < len(states) - 1:
            time.sleep(1)
    
    processing_time = timedelta(minutes=len(states)*15)
    print(f"\nTotal processing time: {format_duration(processing_time)}")

def main():
    """Run the complete demonstration"""
    print("=" * 80)
    print_status_message("🚀 TestFlight Status Utilities - Feature Demo", StatusType.INFO, "")
    print("=" * 80)
    
    try:
        # Demo 1: Build status monitoring
        print_status_message("\n1. Build Status Monitoring", StatusType.INFO)
        demo_build_status_monitoring()
        
        # Demo 2: Color-coded output
        print_status_message("\n2. Color-coded Status Output", StatusType.INFO)
        demo_color_coded_output()
        
        # Demo 3: Progress indicators
        print_status_message("\n3. Progress Indicators (X/50 emails processed)", StatusType.INFO)
        batch_results = demo_progress_indicators()
        
        # Demo 4: Report generation
        print_status_message("\n4. Comprehensive Report Generation", StatusType.INFO)
        report = demo_report_generation()
        
        # Summary
        print("\n" + "=" * 80)
        print_status_message("📋 DEMO SUMMARY", StatusType.INFO, "")
        print("=" * 80)
        
        print(f"✅ {colorize_text('Build Status Monitoring', StatusType.SUCCESS)}: Real-time status tracking with color coding")
        print(f"✅ {colorize_text('Progress Indicators', StatusType.SUCCESS)}: Live progress bars with ETA and statistics")
        print(f"✅ {colorize_text('Color-coded Output', StatusType.SUCCESS)}: Success/warning/error state visualization")
        print(f"✅ {colorize_text('Report Generation', StatusType.SUCCESS)}: Comprehensive reports in JSON and text formats")
        
        print(f"\n📊 Invitation Batch Results:")
        successful_text = f"{batch_results['successful']} successful"
        warnings_text = f"{batch_results['warnings']} warnings"
        failed_text = f"{batch_results['failed']} failed"
        print(f"   • {colorize_text(successful_text, StatusType.SUCCESS)}")
        print(f"   • {colorize_text(warnings_text, StatusType.WARNING)}")
        print(f"   • {colorize_text(failed_text, StatusType.ERROR)}")
        
        success_rate = (batch_results['successful'] / 50 * 100)
        print(f"   • Success Rate: {colorize_text(f'{success_rate:.1f}%', StatusType.SUCCESS)}")
        
        print_status_message("\n🎉 Demo completed successfully!", StatusType.SUCCESS)
        print_status_message("The status utilities are ready for production use.", StatusType.INFO)
        
        # Usage reminder
        print(f"\n💡 {colorize_text('Quick Start:', StatusType.INFO)}")
        print("   from status_utils import check_build_status, check_invitation_status, generate_report")
        print("   build_status = check_build_status()")
        print("   invitation_statuses = check_invitation_status(['email1@test.com', 'email2@test.com'])")
        print("   report = generate_report(build_status, invitation_statuses)")
        
        return 0
        
    except KeyboardInterrupt:
        print_status_message("\n\n⏹️ Demo interrupted by user", StatusType.WARNING)
        return 1
    except Exception as e:
        print_status_message(f"\n\n💥 Demo failed: {str(e)}", StatusType.ERROR)
        return 1

if __name__ == "__main__":
    exit_code = main()
    exit(exit_code)
