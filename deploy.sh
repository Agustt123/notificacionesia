#!/bin/bash

echo "🚀 Iniciando instalación del backend de alertas..."

# 1. Actualizar paquetes
echo "📦 Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar Node.js y npm si no están
echo "📥 Instalando Node.js y npm..."
sudo apt install -y nodejs npm

# 3. NO crear carpeta ni cambiar de carpeta — se queda en la actual
# echo "📁 Creando carpeta del proyecto..."
# mkdir -p ~/alerta-backend && cd ~/alerta-backend

echo "📁 Usando carpeta actual: $(pwd)"

# 4. Crear package.json básico en la carpeta actual
echo "📄 Generando package.json..."
cat <<EOF > package.json
{
  "name": "alerta-backend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "firebase-admin": "^11.5.0"
  }
}
EOF

# 5. Instalar dependencias en la carpeta actual
echo "📦 Instalando dependencias..."
npm install

# 6. Crear index.js básico en la carpeta actual
echo "🧠 Creando index.js de ejemplo..."
cat <<EOF > index.js
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
  console.log(\`🚨 Backend escuchando en http://localhost:\${PORT}\`);
});
EOF

# 7. Crear tokens.js base en la carpeta actual
echo "🔑 Creando tokens.js..."
cat <<EOF > tokens.js
export const TOKENS = {
  "demoToken123": "fcm_token_de_prueba"
};
EOF

echo "✅ Listo. Subí tu archivo 'serviceAccountKey.json' a esta carpeta ($(pwd)) y ejecutá:"
echo ""
echo "  npm start"
echo ""
echo "🔥 El backend de alertas ya está listo para funcionar."
