import db from '../db/database.js';

const isPostgres =
  process.env.NODE_ENV === 'production' && process.env.DATABASE_URL;

// função que retorna todas as tasks
export const getTasks = async (req, res) => {
  try {
    if (isPostgres) {
      const result = await db.query(
        'SELECT id, title, created_at FROM tasks ORDER BY id DESC'
      );
      return res.json(result.rows);
    } else {
      const stmt = db.prepare(
        'SELECT id, title, created_at FROM tasks ORDER BY id DESC'
      );
      const rows = stmt.all();
      return res.json(rows);
    }
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erro ao buscar tarefas.' });
  }
};

// cria uma nova task
export const createTask = async (req, res) => {
  try {
    const { title } = req.body;
    if (!title || !String(title).trim()) {
      return res.status(400).json({ error: "O campo 'title' é obrigatório." });
    }

    if (isPostgres) {
      const result = await db.query(
        'INSERT INTO tasks (title) VALUES ($1) RETURNING id, title, created_at',
        [title.trim()]
      );
      return res.status(201).json(result.rows[0]);
    } else {
      const insert = db.prepare('INSERT INTO tasks (title) VALUES (?)');
      const info = insert.run(title.trim());

      const get = db.prepare(
        'SELECT id, title, created_at FROM tasks WHERE id = ?'
      );
      const newTask = get.get(info.lastInsertRowid);

      return res.status(201).json(newTask);
    }
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erro ao criar tarefa.' });
  }
};

export const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    if (isPostgres) {
      const result = await db.query('DELETE FROM tasks WHERE id = $1', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({ error: 'Tarefa não encontrada' });
      }
    } else {
      const stmt = db.prepare('DELETE FROM tasks WHERE id = ?');
      const result = stmt.run(id);

      if (result.changes === 0) {
        return res.status(404).json({ error: 'Tarefa não encontrada' });
      }
    }

    res.json({ success: true, message: 'Tarefa removida com sucesso' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erro ao deletar tarefa.' });
  }
};
