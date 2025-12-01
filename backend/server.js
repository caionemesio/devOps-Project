import express from "express";
import cors from "cors";
import router from "./src/routes/tasks.routes.js";

const app = express();

// Middlewares
app.use(cors()); // permite requests do frontend (Cross-Origin)
app.use(express.json()); // parse autom. de JSON em req.body

// Health Check - usado pelo Docker e load balancers
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
  });
});

// Rotas da aplicação
app.use("/tasks", router);

// Rota raiz
app.get("/", (req, res) => {
  res.json({
    message: "API DevOps Project",
    version: "1.0.0",
    endpoints: {
      health: "/health",
      tasks: "/tasks",
    },
  });
});

// Start
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor rodando em http://localhost:${PORT}`);
  console.log(`📊 Ambiente: ${process.env.NODE_ENV || 'development'}`);
});
