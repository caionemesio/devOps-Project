import express from "express";
import {
  createTask,
  deleteTask,
  getTasks,
} from "../controllers/tasks.controller.js";

const router = express.Router();

router.get("/", getTasks);
router.post("/", createTask);
router.delete("/:id", deleteTask);

export default router;
