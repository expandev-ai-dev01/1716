import { Outlet } from 'react-router-dom';

export const AppLayout = () => {
  return (
    <div className="min-h-screen bg-white">
      {/* Header can go here */}
      <main>
        <Outlet />
      </main>
      {/* Footer can go here */}
    </div>
  );
};
