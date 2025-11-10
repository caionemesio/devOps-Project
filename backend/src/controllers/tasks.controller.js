import db from "../db/database.js";

// função que retorna todas as tasks
export const getTasks = (req, res) => {
  try {
    const stmt = db.prepare(
      "SELECT id, title, created_at FROM tasks ORDER BY id DESC"
    );
    const rows = stmt.all();
    return res.json(rows);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Erro ao buscar tarefas." });
  }
};

// cria uma nova task
export const createTask = (req, res) => {
  try {
    const { title } = req.body;
    if (!title || !String(title).trim()) {
      return res.status(400).json({ error: "O campo 'title' é obrigatório." });
    }

    const insert = db.prepare("INSERT INTO tasks (title) VALUES (?)");
    const info = insert.run(title.trim()); // info.lastInsertRowid

    const get = db.prepare(
      "SELECT id, title, created_at FROM tasks WHERE id = ?"
    );
    const newTask = get.get(info.lastInsertRowid);

    return res.status(201).json(newTask);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Erro ao criar tarefa." });
  }
};

export const deleteTask = (req, res) => {
  const { id } = req.params;

  const stmt = db.prepare("DELETE FROM tasks WHERE id = ?");
  const result = stmt.run(id);

  if (result.changes === 0) {
    return res.status(404).json({ error: "Tarefa não encontrada" });
  }

  res.json({ success: true, message: "Tarefa removida com sucesso" });
};
