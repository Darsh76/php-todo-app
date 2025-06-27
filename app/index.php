<?php
session_start();

// Redis test
$redis = new Redis();

try {
    $redis->connect('127.0.0.1', 6379);

    // Get Redis replication info
    $info = $redis->info('replication');
    $role = $info['role'] ?? 'unknown';

    if ($role === 'slave') {
        $masterHost = $info['master_host'] ?? 'unknown';
        $message = "🟢 Connected to Redis <strong>replica</strong><br>📡 Master IP: <strong>$masterHost</strong>";

        // Optional: read a key from replica
        $status = $redis->get("status");
        if ($status) {
            $message .= "<br>📦 Status key: $status";
        }

    } elseif ($role === 'master') {
        $redis->set("status", "✅ Redis is working!");
        $message = "✅ Connected to Redis <strong>master</strong> and able to write.";
    } else {
        $message = "⚠️ Connected to Redis but role is <strong>unknown</strong>.";
    }

} catch (Exception $e) {
    $message = "❌ Redis connection failed: " . $e->getMessage();
}


// Initialize session task list if not set
if (!isset($_SESSION['tasks'])) {
    $_SESSION['tasks'] = [];
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Simple To-Do List</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h2>My To-Do List 🚀 Deployed via Bitbucket!</h2>

        <!-- Redis status message -->
        <div style="padding: 10px; margin-bottom: 15px; text-align: center; background: #e8ffe8; border: 1px solid #8c8;">
            <?php echo $message; ?>
        </div>

        <!-- Task Form -->
        <form action="add.php" method="POST">
            <input type="text" name="task" placeholder="Enter a new task" required>
            <button type="submit">Add Task</button>
        </form>

        <!-- Task List -->
        <ul>
            <?php foreach ($_SESSION['tasks'] as $index => $task): ?>
                <li>
                    <?php echo htmlspecialchars($task); ?>
                    <a href="delete.php?index=<?php echo $index; ?>" class="delete">Delete</a>
                </li>
            <?php endforeach; ?>
        </ul>
    </div>
</body>
</html>
