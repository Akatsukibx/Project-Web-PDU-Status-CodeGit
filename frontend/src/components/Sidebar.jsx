import React, { useState, useEffect } from 'react';
import { fetchPDUList } from '../api/pduService';

const Sidebar = ({ activeNode, onSelectNode, pduList, loaded, isOpen }) => {
    const [isExpanded, setIsExpanded] = useState(true);

    const groupedPDUs = pduList.reduce((acc, pdu) => {
        // ... (existing logic)
        const loc = pdu.location || 'Unknown';
        if (!acc[loc]) acc[loc] = [];
        acc[loc].push(pdu);
        return acc;
    }, {});

    return (
        <aside className={`sidebar ${isOpen ? 'open' : ''}`}>
            <div className="sidebar-header">
                PDU MONITOR
            </div>

            <div className="menu-group">
                <button
                    className={`menu-header ${isExpanded ? 'active' : 'collapsed'}`}
                    onClick={() => setIsExpanded(!isExpanded)}
                >
                    <span>Locations</span>
                    <span className="menu-arrow">▼</span>
                </button>

                <ul className={`node-list ${isExpanded ? 'expanded' : 'collapsed'}`}>
                    {Object.keys(groupedPDUs).map(location => (
                        <li key={location} className="node-item">
                            <button
                                className={`node-btn ${activeNode === location ? 'active' : ''}`}
                                onClick={() => onSelectNode(location)}
                            >
                                {location}
                            </button>
                        </li>
                    ))}
                    {!loaded && <div style={{ padding: '1rem', color: '#666' }}>Loading...</div>}
                </ul>
            </div>
        </aside>
    );
};

export default Sidebar;
