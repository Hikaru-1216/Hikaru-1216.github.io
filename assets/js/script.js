// Function to display real-time clock
function startClock() {
    const clockElement = document.getElementById('clock');
    setInterval(() => {
        const now = new Date();
        const formattedTime = now.toISOString().slice(0, 19).replace('T', ' ');
        clockElement.innerText = formattedTime;
    }, 1000);
}

// Function to calculate basic statistics
function calculateStatistics(numbers) {
    if (!numbers || numbers.length === 0) return null;
    const total = numbers.reduce((acc, num) => acc + num, 0);
    const mean = total / numbers.length;
    const min = Math.min(...numbers);
    const max = Math.max(...numbers);
    return { mean, min, max };
}