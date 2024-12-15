const express = require('express');
const bodyParser = require('body-parser');
const pool = require('./connect');
const app = express();
const path = require('path');

// middlewares
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static('public'));
app.set('view engine', 'ejs');
app.use(express.static(path.join(__dirname, "public")));

// routes 
const routes = require('./routes/routes');
app.use('/', routes);

const PORT = 3003;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
