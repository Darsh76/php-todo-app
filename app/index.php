<?php
session_start();

// Load Composer autoloader and .env
require_once __DIR__ . '/../vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->load();

// Load environment values
$appTitle    = getenv('APP_TITLE') ?: 'My To-Do List';
$appVersion  = getenv('APP_VERSION') ?: 'v0.0.1';
$footerText  = getenv('FOOTER_TEXT') ?: 'Default deployment footer';

// Redis status
$redisMessage = '';
$masterStatus = '❌ Unknown';
$redisRole = 'Unknown';
$masterHost = 'N/A';

try {
    $redis = new Redis();
    $redis->connect('127.0.0.1', 6379);

    $info = $redis->info('replication');
    $redisRole = $info['role'] ?? 'unknown';

    if ($redisRole === 'master') {
        $redis->set("status", "✅ Redis master is working");
        $redisMessage = "✅ Role: <strong>master</strong><br>📦 Status key set.";
    } elseif ($redisRole === 'slave') {
        $masterHost = $info['master_host'] ?? 'N/A';
        $masterPort = $info['master_port'] ?? '6379';
        $masterLinkStatus = $info['master_link_status'] ?? 'unknown';

        $masterStatus = $masterLinkStatus === 'up' ? '🟢 UP' : '🔴 DOWN';

        $redisMessage = "🟢 Role: <strong>replica</strong><br>" .
                        "📡 Master IP: <strong>$masterHost:$masterPort</strong><br>" .
                        "🩺 Master link status: <strong>$masterStatus</strong>";

        if ($status = $redis->get("status")) {
            $redisMessage .= "<br>📦 Redis status key: $status";
        }
    } else {
        $redisMessage = "⚠️ Connected to Redis but role is <strong>unknown</strong>.";
    }
} catch (Exception $e) {
    $redisMessage = "❌ Redis connection failed: " . $e->getMessage();
}

// Session task list
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

    <!-- Redis status -->
    <div style="padding:10px; margin-bottom:15px; background:#f8f8ff; border:1px solid #ccc; text-align:center;">
        <?= $redisMessage ?>
    </div>

    <!-- Task form -->
    <form action="add.php" method="POST">
        <input type="text" name="task" placeholder="Enter a new task" required>
        <button type="submit">Add Task</button>
    </form>

    <!-- Task list -->
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
