import { useState } from "react";
import { useTasks } from "./service/useTasks";

function App() {
  const { tasks, loading, addTask, deleteTask } = useTasks();
  const [title, setTitle] = useState("");

  async function handleAddTask() {
    await addTask(title);
    setTitle("");
  }

  return (
    <div style={styles.container}>
      <h1 style={styles.title}>📝 To-Do List</h1>

      <div style={styles.form}>
        <input
          style={styles.input}
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Digite uma nova tarefa"
        />
        <button style={styles.button} onClick={handleAddTask}>
          Adicionar
        </button>
      </div>

      {loading ? (
        <p>Carregando...</p>
      ) : (
        <ul style={styles.list}>
          {tasks.map((task) => (
            <li key={task.id} style={styles.item}>
              <span>{task.title}</span>
              <button
                onClick={() => deleteTask(task.id)}
                style={styles.deleteButton}
              >
                ❌
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default App;

// 🎨 Estilos (mesmo que antes)
const styles = {
  container: {
    fontFamily: "sans-serif",
    maxWidth: "500px",
    margin: "50px auto",
    padding: "20px",
    backgroundColor: "#f5f5f5",
    borderRadius: "10px",
    boxShadow: "0 0 10px rgba(0,0,0,0.1)",
  },
  title: { textAlign: "center", marginBottom: "20px" },
  form: { display: "flex", gap: "10px" },
  input: {
    flex: 1,
    padding: "10px",
    borderRadius: "5px",
    border: "1px solid #ccc",
  },
  button: {
    backgroundColor: "#007bff",
    color: "#fff",
    border: "none",
    padding: "10px 15px",
    borderRadius: "5px",
    cursor: "pointer",
  },
  list: { listStyle: "none", padding: 0, marginTop: "20px" },
  item: {
    backgroundColor: "#fff",
    marginBottom: "10px",
    padding: "10px",
    borderRadius: "5px",
    border: "1px solid #ddd",
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
  },
  deleteButton: {
    background: "transparent",
    border: "none",
    cursor: "pointer",
    fontSize: "18px",
  },
};
