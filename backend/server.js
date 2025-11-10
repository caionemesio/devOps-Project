import express from "express";
import cors from "cors";
import router from "./src/routes/tasks.routes.js";

const app = express();

// Middlewares
app.use(cors()); // permite requests do frontend (Cross-Origin)
app.use(express.json()); // parse autom. de JSON em req.body

// Rotas
app.use("/tasks", router);

// Start
const PORT = process.env.PORT || 3000;
app.listen(PORT, () =>
  console.log(`Servidor rodando em http://localhost:${PORT}`)
);
