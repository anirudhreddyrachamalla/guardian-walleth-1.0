import { BrowserRouter, Route, Routes } from 'react-router-dom';
import Layout from './Components/Layout';

function App() {
  return (
    <BrowserRouter>
    <Routes>
      <Route exact path={`${process.env.PUBLIC_URL}/`} element={<Layout />} />
    </Routes>
    </BrowserRouter>
  );
}

export default App;
