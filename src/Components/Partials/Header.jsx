import React, { useEffect, useRef, useState } from "react";
import { ethers } from "ethers";
import Logo from "../../logo.svg";

const useOutdropdown = (ref, setShow) => {
  useEffect(() => {
    function handleClickOutside(event) {
      if (ref.current && !ref.current.contains(event.target)) {
        setShow(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [ref]);
};

function Header(props) {
  const [connected, setConnected] = useState(props.connected);
  const [defaultAccount, setDefaultAccount] = useState(null);
  const [errorMsg, setErrorMsg] = useState(null);
  const [showMenu, setShowMenu] = useState(false);

  useEffect(() => {
    setConnected(props.connected);
  }, [props.connected]);

  const settingsDropdownRef = useRef(null);
  useOutdropdown(settingsDropdownRef, setShowMenu);

  const handleConnect = async () => {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      if (defaultAccount) {
        setDefaultAccount(null);
        setConnected(null);
        props.connectWallet(null);
      } else {
        provider.send("eth_requestAccounts", []);
        const signer = await provider.getSigner();
        const signIn = await signer.signMessage("Welcome to Guardian WallETH");
        const address = await signer.getAddress();
        setDefaultAccount(address);
        // setConnected(address);
        props.connectWallet(signIn);
      }
    } else {
      setErrorMsg("Please Install Metamask!!!");
    }
  };

  const handleUserClick = () => {
    setShowMenu(!showMenu);
  };

  return (
    <div className="sticky h-12 mb-2 bg-background-color-1 text-font-color-1 w-full p-1 max-w-full ">
      <nav className="container flex items-center justify-between mx-auto">
        <div className="border p-2">
          <div className="">
            <span className="capitalize">Guardian WallETH</span>
          </div>
        </div>
        <div className="">
          {connected ? (
            <div className="relative">
              <span
                onClick={handleUserClick}
                className="flex items-center text-gray-700 text-opacity-50 whitespace-nowrap relative pt-2.5 px-3 cursor-pointer"
              >
                <img
                  src={Logo}
                  className="rounded-full h-8 w-8 align-middle"
                  alt="Avatar"
                />
                <span className="hidden md:inline-block ml-2 cursor-pointer text-white">
                  {defaultAccount.substr(0, 5)}...{defaultAccount.substr(38)}
                </span>
              </span>
              <div
                ref={settingsDropdownRef}
                onClick={() => setShowMenu(false)}
                className={`absolute right-0 md:left-0 z-1300 ${
                  showMenu ? "block" : "hidden"
                } min-w-10 text-base text-white text-left bg-black border rounded-md border-gray-300`}
              >
                <div
                  onClick={handleConnect}
                  className="block w-full clear-both font-normal cursor-pointer text-inherit whitespace-nowrap bg-transparent border-0 text-gray-700 text-opacity-50 text-xs py-1.5 px-4"
                >
                  Logout
                </div>
              </div>
            </div>
          ) : (
            <button type="button" className="bg-white text-black px-2 py-1" onClick={handleConnect}>
              Connect Wallet
            </button>
          )}
        </div>
      </nav>
    </div>
  );
}

export default Header;
