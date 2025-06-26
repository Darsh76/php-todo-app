<?php
session_start();

// Redis test
try {
    $redis = new Redis();
    $redis->connect('todo-redis-slave', 6379); // service name in docker-compose.yml
    $redis->set("status", "✅ Redis is working!");
    $message = $redis->get("status");
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
        <h2>My To-Do List</h2>

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
