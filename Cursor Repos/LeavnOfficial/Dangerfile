# Dangerfile for LeavnSuperOfficial

# Ensure PR has a description
fail("Please provide a description for this PR") if github.pr_body.length < 10

# Warn for large PRs
warn("This PR is quite large. Consider breaking it into smaller PRs") if git.lines_of_code > 500

# Check for WIP
warn("PR is marked as Work in Progress") if github.pr_title.include?("[WIP]") || github.pr_title.include?("WIP:")

# Ensure tests are included for new features
has_app_changes = !git.modified_files.grep(/Sources/).empty?
has_test_changes = !git.modified_files.grep(/Tests/).empty?

if has_app_changes && !has_test_changes
  warn("This PR modifies app code but doesn't include tests. Please add tests.")
end

# Check for focused tests
focused_tests = git.modified_files.select { |file| file.end_with?(".swift") }.map { |file| File.read(file) }.join("\n").scan(/fit\(|fdescribe\(|fcontext\(/)
fail("Focused tests detected. Please remove them before merging.") unless focused_tests.empty?

# SwiftLint
swiftlint.config_file = ".swiftlint.yml"
swiftlint.lint_files inline_mode: true

# Check for TODO/FIXME comments
todoist.message = "There are still some things to do in this PR:"
todoist.keyword_regex = /(?:TODO|FIXME|HACK|XXX)/
todoist.fail_for_todos = false
todoist.warn_for_todos = true

# Check for print statements in production code
git.modified_files.select { |f| f.end_with?(".swift") && !f.include?("Test") }.each do |file|
  next unless File.exist?(file)
  
  File.readlines(file).each_with_index do |line, index|
    if line.include?("print(")
      warn("Print statement found in #{file}:#{index + 1}. Consider using proper logging.", file: file, line: index + 1)
    end
  end
end

# Encourage small PRs
message("Thanks for keeping this PR small!") if git.lines_of_code < 200

# Check for conflicts
fail("This PR has merge conflicts. Please resolve them.") if github.pr_json["mergeable_state"] == "dirty"

# Check commit messages
git.commits.each do |commit|
  if commit.message.length < 10
    fail("Commit message '#{commit.message}' is too short. Please use descriptive commit messages.")
  end
  
  unless commit.message.match?(/^(feat|fix|docs|style|refactor|test|chore|perf|build|ci|revert)(\(.+\))?: .+/)
    warn("Commit message '#{commit.message}' doesn't follow conventional commits format")
  end
end

# Security checks
security_keywords = ["password", "secret", "key", "token", "api_key", "apikey"]
git.modified_files.each do |file|
  next unless File.exist?(file)
  
  content = File.read(file)
  security_keywords.each do |keyword|
    if content.downcase.include?(keyword) && !file.include?("Test")
      warn("Potential security concern: '#{keyword}' found in #{file}. Please ensure no sensitive data is committed.")
    end
  end
end

# Performance considerations
if git.modified_files.any? { |f| f.include?("Service") || f.include?("Client") }
  message("This PR modifies service/client code. Please ensure performance implications are considered.")
end

# Documentation reminder
if git.modified_files.any? { |f| f.end_with?(".swift") && f.include?("/Sources/") }
  modified_public_apis = false
  
  git.modified_files.select { |f| f.end_with?(".swift") }.each do |file|
    next unless File.exist?(file)
    
    content = File.read(file)
    if content.include?("public func") || content.include?("public class") || content.include?("public struct")
      modified_public_apis = true
      break
    end
  end
  
  warn("This PR modifies public APIs. Please ensure documentation is updated.") if modified_public_apis
end

# Changelog reminder
unless git.modified_files.include?("CHANGELOG.md")
  warn("Please update CHANGELOG.md with your changes")
end

# Final message
message("Great job! This PR is ready for review 🎉") if status_report[:errors].empty? && status_report[:warnings].empty?