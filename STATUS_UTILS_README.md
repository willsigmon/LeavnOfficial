# TestFlight Status Checking and Reporting Utilities

## Overview

The `status_utils.py` module provides comprehensive status checking and reporting features for TestFlight invitation processes. It includes real-time build monitoring, invitation status tracking, progress indicators, and detailed report generation.

## Key Features

### 1. Build Status Monitoring
- **`check_build_status()`** - Verify TestFlight build processing status
- Real-time monitoring with color-coded status indicators
- Processing time tracking
- Support for waiting until build is ready

### 2. Invitation Status Checking
- **`check_invitation_status(emails)`** - Query status of sent invitations
- Batch processing with progress tracking
- Identifies invited, not invited, and existing testers
- Error handling for failed lookups

### 3. Progress Indicators
- Live progress bars showing X/50 emails processed
- Real-time ETA calculations
- Color-coded success/failure/warning counts
- Terminal-friendly output with proper refresh

### 4. Report Generation
- **`generate_report()`** - Create comprehensive summary reports
- Multiple output formats (JSON, TXT)
- Statistical analysis of invitation campaigns
- Actionable recommendations
- Customizable output directory

### 5. Color-Coded Output
- ✅ **Success** - Green highlighting for successful operations
- ⚠️ **Warning** - Yellow highlighting for warnings
- ❌ **Error** - Red highlighting for errors
- ℹ️ **Info** - Blue highlighting for informational messages
- 🔄 **Processing** - Cyan highlighting for ongoing operations

## Quick Start

```python
from status_utils import check_build_status, check_invitation_status, generate_report

# Check build status
build_status = check_build_status()

# Check invitation status for a list of emails
emails = ['user1@example.com', 'user2@example.com', 'user3@example.com']
invitation_statuses = check_invitation_status(emails)

# Generate comprehensive report
report = generate_report(build_status, invitation_statuses, save_to_file=True)
```

## Advanced Usage

### Using the StatusChecker Class

```python
from status_utils import StatusChecker

# Initialize with custom API client
checker = StatusChecker()

# Wait for build to be ready
build_status = checker.wait_for_build_ready(
    timeout_minutes=30,
    check_interval=60
)

# Check specific app
invitation_statuses = checker.check_invitation_status(
    emails=['test@example.com'],
    app_id='your_app_id'
)
```

### Custom Progress Bars

```python
from status_utils import ProgressBar

# Create progress bar for batch processing
progress = ProgressBar(total=100, width=50, show_eta=True)

for i in range(100):
    # Your processing logic here
    progress.update(i+1, successful=i, failed=0, warnings=0)
    progress.print_progress()
```

### Custom Report Generation

```python
from status_utils import ReportGenerator

# Create report generator with custom output directory
generator = ReportGenerator("./my_reports")

# Generate report with additional data
additional_data = {
    "campaign_name": "Beta Release 2.0",
    "target_audience": "Premium users",
    "notes": "First release with new features"
}

report = generator.generate_report(
    build_status=build_status,
    invitation_statuses=invitation_statuses,
    additional_data=additional_data
)

# Save in multiple formats
generator.save_report(report, "campaign_report.json", "json")
generator.save_report(report, "campaign_report.txt", "txt")
```

## Data Classes

### BuildStatus
```python
@dataclass
class BuildStatus:
    build_id: str
    version: str
    build_number: str
    processing_state: str
    uploaded_date: str
    last_checked: datetime
    processing_time: Optional[timedelta] = None
    is_ready: bool = False
    error_message: Optional[str] = None
```

### InvitationStatus
```python
@dataclass
class InvitationStatus:
    email: str
    tester_id: Optional[str]
    status: str  # "invited", "not_invited", "exists_not_invited", "error"
    invited_date: Optional[datetime]
    last_checked: datetime
    error_message: Optional[str] = None
    build_version: Optional[str] = None
    app_id: Optional[str] = None
```

## Report Structure

Generated reports include:

1. **Build Information**
   - Version and build number
   - Processing state and readiness
   - Processing time

2. **Invitation Summary**
   - Total checked
   - Successfully invited count
   - Not invited count
   - Error count
   - Success rate percentage

3. **Detailed Results**
   - List of invited testers
   - List of not invited testers
   - List of errors with messages
   - List of existing but not invited testers

4. **Statistics**
   - Invitation success rate
   - Error rate
   - Total existing testers
   - New testers needed

5. **Recommendations**
   - Actionable next steps based on results

## Color Terminal Support

The utilities automatically detect terminal capabilities and gracefully degrade if colors are not supported. ANSI color codes are used for maximum compatibility.

## Error Handling

All functions include comprehensive error handling:
- API connection errors are caught and reported
- Rate limiting is handled with exponential backoff
- Network timeouts are managed gracefully
- Clear error messages guide troubleshooting

## Testing

Run the test suite:
```bash
python test_status_utils.py
```

Run the feature demo (no credentials required):
```bash
python demo_status_features.py
```

## Requirements

- Python 3.7+
- Dependencies from `app_store_api.py`:
  - PyJWT
  - cryptography
  - requests
  - python-dotenv

## License

Part of the Leavn TestFlight automation suite.
