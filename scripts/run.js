/**
 * Cross-Platform Runner for Robot QA Lab.
 * Automatically resolves the virtual environment Python executable (.venv)
 * across Windows (PowerShell, CMD, Git Bash) and POSIX (macOS, Linux).
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const rootDir = path.resolve(__dirname, '..');

function getPythonExecutable() {
  const candidates = [
    path.join(rootDir, '.venv', 'Scripts', 'python.exe'),
    path.join(rootDir, '.venv', 'bin', 'python'),
    path.join(rootDir, 'venv', 'Scripts', 'python.exe'),
    path.join(rootDir, 'venv', 'bin', 'python'),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  return process.platform === 'win32' ? 'python' : 'python3';
}

const pythonExe = getPythonExecutable();
const rawArgs = process.argv.slice(2);

let scriptToRun = path.join(__dirname, 'run_all.py');

const filteredArgs = [];
for (const arg of rawArgs) {
  if (arg === '--metrics-only') {
    scriptToRun = path.join(__dirname, 'generate_metrics.py');
  } else if (arg === '--check-env-only') {
    scriptToRun = path.join(__dirname, 'check_env.py');
  } else if (arg === '--ai-only') {
    scriptToRun = path.join(__dirname, 'ai_qa_observer.py');
  } else {
    filteredArgs.push(arg);
  }
}

const child = spawn(pythonExe, [scriptToRun, ...filteredArgs], {
  cwd: rootDir,
  stdio: 'inherit',
  env: process.env,
  shell: false,
});

child.on('error', (err) => {
  console.error('\n❌ Erro ao iniciar Python runtime:', err.message);
  console.error('Certifique-se de que o ambiente virtual está criado em .venv\n');
  process.exit(1);
});

child.on('exit', (code) => {
  process.exit(code !== null ? code : 0);
});
