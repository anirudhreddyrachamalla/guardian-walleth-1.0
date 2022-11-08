import React, { useEffect, useState } from "react";
import Logo from "../logo.svg";

function LandingPage(props) {
    const [connected, setConnected] = useState(props.connected);

    useEffect(()=>{
        setConnected(props.connected);
    },[props.connected]);

    const handleGetStarted = () =>{
        props.setSteps(1);
    }

  return (
    <>
        <div className="w-2/5">
        <img src={Logo} alt="wallet" />
        </div>
        <div className="w-full text-center">
            <p className="text-left">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            </p>
            <button onClick={handleGetStarted} disabled={!connected} type="button" className={` ${!connected?"bg-slate-400":"bg-success-btn"} mt-4 p-2 rounded text-white`}>
                Get Started
            </button>
        </div>
        </>
  );
}

export default LandingPage;
