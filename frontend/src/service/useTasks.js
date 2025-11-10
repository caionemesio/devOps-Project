import { useState, useEffect } from "react";
import { api } from "../api/apiCreate";

export function useTasks() {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(false);

  // 🔹 Buscar todas as tarefas
  async function fetchTasks() {
    try {
      setLoading(true);
      const { data } = await api.get(`/tasks`);
      setTasks(data);
    } catch (error) {
      console.error("Erro ao buscar tarefas:", error);
    } finally {
      setLoading(false);
    }
  }

  // 🔹 Adicionar uma nova tarefa
  async function addTask(title) {
    if (!title.trim()) return alert("Digite uma tarefa!");
    try {
      const { data } = await api.post(`/tasks`, { title });
      setTasks((prev) => [...prev, data]);
    } catch (error) {
      console.error("Erro ao adicionar tarefa:", error);
    }
  }

  // 🔹 Excluir uma tarefa
  async function deleteTask(id) {
    try {
      await api.delete(`/tasks/${id}`);
      setTasks((prev) => prev.filter((task) => task.id !== id));
    } catch (error) {
      console.error("Erro ao excluir tarefa:", error);
    }
  }

  useEffect(() => {
    fetchTasks();
  }, []);

  return { tasks, loading, fetchTasks, addTask, deleteTask };
}
