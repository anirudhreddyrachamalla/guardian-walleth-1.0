import React, { useState } from "react";
import 'react-toastify/dist/ReactToastify.css';
import { ToastContainer } from "react-toastify";
import Guardians from "./Guardians";
import LandingPage from "./LandingPage";
import Controls from "./Partials/Controls";
import Header from "./Partials/Header";

function Layout() {
  const [connected, setConnected] = useState(false);
  const [steps, setSteps] = useState(0);
  const [data, setData] = useState({});

  const connectWallet = (value) => {
    if (value) {
    } else {
      setSteps(0);
    }
    setConnected(value);
  };

  const updateFromChild = (value) =>{
    setData({...data, ...value});
    console.log({...data, ...value});
  }

  return (
    <div className="container max-w-full">
      <Header connectWallet={connectWallet} connected={connected} />
      <div className="container w-3/4 mt-12 mx-auto flex justify-center items-center flex-col max-w-full bg-backgroung-color text-font-color rounded p-6 border border-black shadow-sm shadow-slate-400">
        {steps ? (
          steps === 1 ? (
            <Guardians connected={connected} setSteps={setSteps} updateParent={updateFromChild} />
          ) : (
            <Controls updateParent={updateFromChild} />
          )
        ) : (
          <LandingPage connected={connected} setSteps={setSteps} />
        )}
      </div>
      <ToastContainer />
    </div>
  );
}

export default Layout;
