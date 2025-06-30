<?php
session_start();

// 🔐 ENV from SSM
$appTitle = getenv('APP_TITLE') ?: 'My To-Do List';
$appVersion = getenv('APP_VERSION') ?: 'v0.0.1';
$footerText = getenv('FOOTER_TEXT') ?: 'Deployed locally';

// 🔁 Redis test
$redisMessage = '';
try {
    $redis = new Redis();
    $redis->connect('127.0.0.1', 6379); // local Redis inside the container

    $info = $redis->info('replication');
    $role = $info['role'] ?? 'unknown';

    if ($role === 'slave') {
        $redisMessage = "🟢 Connected to Redis <strong>replica</strong><br>📡 Master: <strong>" . ($info['master_host'] ?? 'unknown') . "</strong>";
        if ($status = $redis->get("status")) {
            $redisMessage .= "<br>📦 Redis status key: $status";
        }
    } elseif ($role === 'master') {
        $redis->set("status", "✅ Redis is working!");
        $redisMessage = "✅ Connected to Redis <strong>master</strong> and wrote test key.";
    } else {
        $redisMessage = "⚠️ Redis connected, but unknown role.";
    }

} catch (Exception $e) {
    $redisMessage = "❌ Redis connection failed: " . $e->getMessage();
}

// Session setup
if (!isset($_SESSION['tasks'])) {
    $_SESSION['tasks'] = [];
}
?>

<!DOCTYPE html>
<html>
<head>
    <title><?= htmlspecialchars($appTitle) ?></title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <h2><?= htmlspecialchars($appTitle) ?></h2>

    <!-- Redis Status -->
    <div style="padding:10px; margin-bottom:15px; background:#f8f8ff; border:1px solid #ccc; text-align:center;">
        <?= $redisMessage ?>
    </div>

    <!-- Form -->
    <form action="add.php" method="POST">
        <input type="text" name="task" placeholder="Enter a new task" required>
        <button type="submit">Add Task</button>
    </form>

    <!-- Task List -->
    <ul>
        <?php foreach ($_SESSION['tasks'] as $index => $task): ?>
            <li>
                <?= htmlspecialchars($task) ?>
                <a href="delete.php?index=<?= $index ?>" class="delete">Delete</a>
            </li>
        <?php endforeach; ?>
    </ul>

    <!-- Footer -->
    <div style="text-align:center; font-size:12px; margin-top:30px;">
        <hr>
        <p>Version: <?= htmlspecialchars($appVersion) ?></p>
        <p><?= htmlspecialchars($footerText) ?></p>
    </div>
</div>
</body>
</html>
