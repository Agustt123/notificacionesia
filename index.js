import express from 'express';
import admin from 'firebase-admin';
import fs from 'fs';

import { TOKENS } from './tokens.js';

const app = express();
app.use(express.json());

admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(fs.readFileSync('./serviceAccountKey.json')))
});

app.post('/alerta', async (req, res) => {
  const { token, tipo, mensaje } = req.body;

  if (!token || !tipo || !mensaje) {
    return res.status(400).json({ error: 'Faltan datos' });
  }

  const fcmToken = TOKENS[token];
  if (!fcmToken) {
    return res.status(403).json({ error: 'Token inválido' });
  }

  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: tipo.toUpperCase(),
        body: mensaje
      },
      data: {
        tipo,
        mensaje
      }
    });

    res.json({ status: 'Enviado con éxito' });
  } catch (err) {
    console.error('Error al enviar', err);
    res.status(500).json({ error: 'No se pudo enviar la alerta' });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚨 Backend escuchando en http://localhost:${PORT}`);
});
