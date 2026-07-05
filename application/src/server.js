const express = require('express');
const mongoose = require('mongoose');
const app = express();
const port = 3000;

app.use(express.json());

// REQUIREMENT: Connect to MongoDB via Environment Variable
const mongoURI = process.env.MONGO_URI;

if (!mongoURI) {
    console.error("MONGO_URI environment variable is missing!");
    process.exit(1);
}

// Connect to MongoDB without authentication checks for the lab
mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('Connected to MongoDB successfully!'))
    .catch(err => console.error('MongoDB connection error:', err));

const Task = mongoose.model('Task', new mongoose.Schema({ title: String }));

app.get('/', (req, res) => res.send('Wiz Tech Exercise - WebApp is running!'));

app.get('/tasks', async (req, res) => {
    const tasks = await Task.find();
    res.json(tasks);
});

app.post('/tasks', async (req, res) => {
    const task = new Task({ title: req.body.title });
    await task.save();
    res.status(201).json(task);
});

app.listen(port, () => console.log(`App listening on port ${port}`));