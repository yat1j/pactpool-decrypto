const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

// ✅ serve all static files
app.use(express.static(__dirname));

// ✅ route for home page
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

// ✅ route for dashboard
app.get("/dashboard", (req, res) => {
  res.sendFile(path.join(__dirname, "dashboard.html"));
});

// ✅ route for goal wall (if separate file)
app.get("/goalwall", (req, res) => {
  res.sendFile(path.join(__dirname, "goalwall.html"));
});

// ✅ fallback (IMPORTANT)
app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});