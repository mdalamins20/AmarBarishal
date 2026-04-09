import React, { useState, useEffect } from 'react';
import { 
  Building2, Hospital, ShoppingBag, PhoneCall, 
  Settings, User, Bell, Search, Moon, Sun, 
  MapPin, Menu, Home, Activity
} from 'lucide-react';

function App() {
  const [darkMode, setDarkMode] = useState(false);
  const [activeMenu, setActiveMenu] = useState('dashboard');

  useEffect(() => {
    if (darkMode) {
      document.documentElement.setAttribute('data-theme', 'dark');
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  }, [darkMode]);

  const categories = [
    { id: 'education', icon: Building2, color: '#3b82f6', bg: 'rgba(59, 130, 246, 0.1)', title: 'শিক্ষা প্রতিষ্ঠান', desc: 'স্কুল, কলেজ ও বিশ্ববিদ্যালয়' },
    { id: 'hospital', icon: Hospital, color: '#10b981', bg: 'rgba(16, 185, 129, 0.1)', title: 'হাসপাতাল', desc: 'জরুরি চিকিৎসা ও ক্লিনিক' },
    { id: 'market', icon: ShoppingBag, color: '#f59e0b', bg: 'rgba(245, 158, 11, 0.1)', title: 'মার্কেট ও শপিং', desc: 'শহর ও আশেপাশের মার্কেট' },
    { id: 'emergency', icon: PhoneCall, color: '#ef4444', bg: 'rgba(239, 68, 68, 0.1)', title: 'জরুরি সেবা', desc: 'পুলিশ, ফায়ার সার্ভিস ও অন্যান্য' },
  ];

  const recentUpdates = [
    { title: 'বরিশাল শেরে বাংলা মেডিকেল কলেজে নতুন ইউনিট চালু', time: '২ ঘন্টা আগে', icon: Activity },
    { title: 'হরতালের কারণে আগামীকালের সকল স্কুল বন্ধ', time: '৫ ঘন্টা আগে', icon: Building2 },
    { title: 'নতুন শপিং কমপ্লেক্সের উদ্বোধন', time: '১ দিন আগে', icon: ShoppingBag },
  ];

  return (
    <div className="app-container">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="logo-container">
          <div className="logo-icon">
            <MapPin size={24} />
          </div>
          <div className="logo-text">আমার বরিশাল</div>
        </div>

        <ul className="nav-menu">
          <li className={`nav-item ${activeMenu === 'dashboard' ? 'active' : ''}`} onClick={() => setActiveMenu('dashboard')}>
            <Home size={20} />
            <span>ড্যাশবোর্ড</span>
          </li>
          <li className={`nav-item ${activeMenu === 'education' ? 'active' : ''}`} onClick={() => setActiveMenu('education')}>
            <Building2 size={20} />
            <span>শিক্ষা প্রতিষ্ঠান</span>
          </li>
          <li className={`nav-item ${activeMenu === 'hospital' ? 'active' : ''}`} onClick={() => setActiveMenu('hospital')}>
            <Hospital size={20} />
            <span>হাসপাতাল</span>
          </li>
          <li className={`nav-item ${activeMenu === 'market' ? 'active' : ''}`} onClick={() => setActiveMenu('market')}>
            <ShoppingBag size={20} />
            <span>মার্কেট</span>
          </li>
          <li className={`nav-item ${activeMenu === 'emergency' ? 'active' : ''}`} onClick={() => setActiveMenu('emergency')}>
            <PhoneCall size={20} />
            <span>জরুরি সেবা</span>
          </li>
          <li style={{ marginTop: 'auto' }} className={`nav-item ${activeMenu === 'settings' ? 'active' : ''}`} onClick={() => setActiveMenu('settings')}>
            <Settings size={20} />
            <span>সেটিংস</span>
          </li>
        </ul>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        <header className="top-header">
          <div className="search-bar">
            <Search size={18} color="var(--text-muted)" />
            <input type="text" placeholder="কী খুঁজছেন? (যেমন: হাসপাতাল, স্কুল)" />
          </div>
          
          <div className="header-actions">
            <button className="icon-btn" onClick={() => setDarkMode(!darkMode)}>
              {darkMode ? <Sun size={20} /> : <Moon size={20} />}
            </button>
            <button className="icon-btn">
              <Bell size={20} />
            </button>
            <button className="icon-btn" style={{ background: 'var(--accent-glow)', color: 'var(--accent-color)' }}>
              <User size={20} />
            </button>
          </div>
        </header>

        <div className="dashboard-content">
          <div className="welcome-banner animate-fade-in">
            <h1>স্বাগতম, আপনার বরিশাল ড্যাশবোর্ডে</h1>
            <p>আপনার শহরের সকল প্রয়োজনীয় তথ্য এক ছাতার নিচে। দ্রুত খুঁজে নিন আপনার কাঙ্খিত সেবা।</p>
          </div>

          <h2 className="section-title animate-fade-in" style={{ animationDelay: '0.1s' }}>গুরুত্বপূর্ণ সেবা সমূহ</h2>
          
          <div className="glass-grid">
            {categories.map((cat, index) => {
              const IconComp = cat.icon;
              return (
                <div className="glass-card animate-fade-in" style={{ animationDelay: `${0.1 + (index * 0.1)}s` }} key={cat.id}>
                  <div className="card-icon" style={{ backgroundColor: cat.bg, color: cat.color }}>
                    <IconComp size={28} />
                  </div>
                  <h3>{cat.title}</h3>
                  <p>{cat.desc}</p>
                </div>
              )
            })}
          </div>

          <h2 className="section-title animate-fade-in" style={{ animationDelay: '0.5s' }}>সাম্প্রতিক আপডেট</h2>
          <div className="updates-list animate-fade-in" style={{ animationDelay: '0.6s' }}>
            {recentUpdates.map((update, idx) => {
              const UpdateIcon = update.icon;
              return (
                <div className="update-item" key={idx}>
                  <div className="update-icon">
                    <UpdateIcon size={20} />
                  </div>
                  <div className="update-content">
                    <h4>{update.title}</h4>
                    <p>{update.time}</p>
                  </div>
                </div>
              );
            })}
          </div>

        </div>
      </main>
    </div>
  );
}

export default App;
