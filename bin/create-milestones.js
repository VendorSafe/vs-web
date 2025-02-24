const fs = require('fs');
const path = require('path');
const readline = require('readline');

(async () => {
  // Dynamically import Octokit to support ESM in a CommonJS module
  const { Octokit } = await import('@octokit/rest');

  // Initialize Octokit with your GitHub token from environment variables
  const octokit = new Octokit({
    auth: process.env.GITHUB_TOKEN,
  });

  async function createMilestonesIssues(inputFile, repo) {
    const [owner, repoName] = repo.split('/');
    if (!owner || !repoName) {
      console.error('Repository must be in the format "owner/repo".');
      process.exit(1);
    }

    const absoluteInputPath = path.isAbsolute(inputFile)
      ? inputFile
      : path.join(__dirname, inputFile);

    const fileStream = fs.createReadStream(absoluteInputPath);

    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity,
    });

    let currentMilestone = null;
    let currentIssue = null;
    let issueBody = '';
    const milestones = [];

    for await (const line of rl) {
      if (/^#\s+/.test(line)) {
        currentMilestone = line.replace(/^#\s+/, '').trim();
        milestones.push({ title: currentMilestone, issues: [] });
        currentIssue = null;
      } else if (/^##\s+/.test(line)) {
        if (!currentMilestone) continue;
        currentIssue = line.replace(/^##\s+/, '').trim();
        milestones[milestones.length - 1].issues.push({ title: currentIssue, body: '', subtasks: [] });
        issueBody = '';
      } else if (/^###\s+/.test(line)) {
        if (!currentIssue) continue;
        const subtask = line.replace(/^###\s+/, '').trim();
        milestones[milestones.length - 1].issues[milestones.length - 1].subtasks.push(subtask);
      } else if (/^---$/.test(line)) {
        continue;
      } else {
        if (currentIssue) {
          issueBody += line + '\n';
          milestones[milestones.length - 1].issues[milestones.length - 1].body = issueBody.trim();
        }
      }
    }

    for (const milestone of milestones) {
      // Check if milestone exists
      const existingMilestones = await octokit.issues.listMilestones({
        owner,
        repo: repoName,
        state: 'open',
      });

      const milestoneExists = existingMilestones.data.find(m => m.title === milestone.title);

      let milestoneNumber;
      if (milestoneExists) {
        console.log(`Milestone "${milestone.title}" already exists. Skipping...`);
        milestoneNumber = milestoneExists.number;
      } else {
        // Create milestone
        const createdMilestone = await octokit.issues.createMilestone({
          owner,
          repo: repoName,
          title: milestone.title,
          state: 'open',
          description: `Milestone for ${milestone.title}`,
          due_on: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // 30 days from now
        });
        milestoneNumber = createdMilestone.data.number;
        console.log(`Created Milestone: "${milestone.title}"`);
      }

      for (const issue of milestone.issues) {
        // Check if issue already exists
        const existingIssues = await octokit.issues.listForRepo({
          owner,
          repo: repoName,
          state: 'all',
          per_page: 100,
        });

        const issueExists = existingIssues.data.find(i => i.title === issue.title);

        if (issueExists) {
          console.log(`Issue "${issue.title}" already exists. Skipping...`);
          continue;
        }

        // Prepare issue body with subtasks
        let body = issue.body;
        if (issue.subtasks.length > 0) {
          body += '\n\n## Subtasks\n';
          issue.subtasks.forEach(subtask => {
            body += `- [ ] ${subtask}\n`;
          });
        }

        // Create issue
        const createdIssue = await octokit.issues.create({
          owner,
          repo: repoName,
          title: issue.title,
          body,
          milestone: milestoneNumber,
          labels: ['To Do'],
        });

        console.log(`Created Issue #${createdIssue.data.number}: "${issue.title}"`);
      }
    }
  }

  // Command-line arguments
  const args = process.argv.slice(2);
  if (args.length !== 2) {
    console.error('Usage: yarn create-milestones-issues');
    console.error('Or: node ./bin/create-milestones.js <MILESTONES.md> <owner/repo>');
    process.exit(1);
  }

  const [inputFile, repo] = args;

  // Execute the function
  createMilestonesIssues(inputFile, repo).catch(error => {
    console.error('Error:', error);
    process.exit(1);
  });
})();