// ── Runtime values ───────────────────────────────────────────────────────────
// These can be overridden by the EC2 User Data script at deploy time.
// The placeholders below are replaced by sed commands in userdata.sh.

const config = {
  version:     document.getElementById("version").textContent     || "v1.0",
  environment: document.getElementById("environment").textContent || "Dev",
};

// ── Deploy timestamp ──────────────────────────────────────────────────────────
const deployTimeEl = document.getElementById("deploy-time");
if (deployTimeEl) {
  const now = new Date();
  deployTimeEl.textContent =
    "Deployed: " +
    now.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" }) +
    " " +
    now.toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" });
}

// ── Console info ──────────────────────────────────────────────────────────────
console.log(
  `%cCapgemini Invent DevOps Demo\n%cVersion: ${config.version} | Env: ${config.environment}`,
  "color:#0070ad;font-size:1.1rem;font-weight:bold;",
  "color:#6b7280;font-size:0.9rem;"
);
