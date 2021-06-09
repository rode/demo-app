'use strict';

const express = require('express');

const PORT = 8081;
const HOST = '0.0.0.0';

const app = express();
app.disable("x-powered-by");

app.get('/', (req, res) => {
    res.send('Hello World');
});

const server = app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);

const signalHandler = (signal) => () => {
  console.log(`Received ${signal}, stopping server`)
  server.close((error) => {
    let exitCode = 0;
    if (error) {
      console.error('Error occurred stopping server', error);
      exitCode = 1;
    }

    process.exit(exitCode)
  });
};

['SIGINT', 'SIGTERM'].forEach((signal) => {
    process.on(signal, signalHandler(signal));
});
