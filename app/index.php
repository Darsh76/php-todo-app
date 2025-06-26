<?php
session_start();

// Redis test
$redis = new Redis();
$redis->connect('todo-redis-slave', 6379);
$message = $redis->get("status") ?: "ℹ️ No status key found on replica.";


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
