// LibraryList.js
import React from 'react';

function LibraryList({ libraries }) {
  return (
    <div>
      <h2>Libraries</h2>
      <ul>
        {libraries.map((lib, index) => (
          <li key={index}>{lib}</li>
        ))}
      </ul>
    </div>
  );
}

export default LibraryList;