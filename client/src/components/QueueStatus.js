// QueueStatus.js
import React from 'react';

function QueueStatus({ status }) {
  return (
    <div>
      <h2>Queue Status</h2>
      {status.length > 0 ? (
        <ul>
          {status.map((item, index) => (
            <li key={index}>
              {item.book} at {item.library}: {item.status} (Updated: {new Date(item.timestamp).toLocaleString()})
            </li>
          ))}
        </ul>
      ) : (
        <p>No queue data yet.</p>
      )}
    </div>
  );
}

export default QueueStatus;