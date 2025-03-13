import React, { useState, useEffect } from 'react';
import axios from 'axios';
import LibraryList from './components/LibraryList';
import QueueStatus from './components/QueueStatus';
import './App.css';

function App() {
  const [user, setUser] = useState(null);
  const [queueStatus, setQueueStatus] = useState([]);
  const xUsername = 'user123'; // Mock; replace with X auth

  useEffect(() => {
    // Register user on mount
    axios.post('http://localhost:5000/api/register', {
      xUsername,
      libraryCard: 'libraryCard456',
    }).then(response => setUser(response.data.user))
      .catch(error => console.error(error));

    // Poll queue status
    const interval = setInterval(() => {
      axios.get(`http://localhost:5000/api/queue/${xUsername}`)
        .then(response => setQueueStatus(response.data))
        .catch(error => console.error(error));
    }, 60000); // Every minute

    return () => clearInterval(interval);
  }, [xUsername]);

  return (
    <div className="App">
      <h1>Library System App</h1>
      {user ? (
        <>
          <LibraryList libraries={user.libraries} />
          <QueueStatus status={queueStatus} />
        </>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
}

export default App;