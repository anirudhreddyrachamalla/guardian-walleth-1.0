import React, { useState } from "react";

function Controls(props) {
  const [controls, setControls] = useState({
    inactivePeriod: 180,
    transactionLimit:1000000000
  });

  const handleFinish = () =>{
    props.updateParent(controls);
  }

  return (
    <>
      <h1 className="text-lg font-bold text-font-color self-start">Control Settings</h1>
      <div className="w-full px-6 mt-12 grid grid-flow-row gap-2">
        <div className="grid grid-cols-6 gap-4">
          <div className="font-medium ">Inactive Period</div>
          <div className="col-span-2">
            <input
              type="text"
                value={controls.inactivePeriod}
                onChange={(e) => setControls({...controls,inactivePeriod:e.target.value})}
              className="w-full border p-1 rounded"
              placeholder="in days"
            />
          </div>
          <div className="col-span-3">

          </div>
          <div className="font-medium">Transaction Limit</div>
          <div className="col-span-2">
            <input
              type="text"
                value={controls.transactionLimit}
                onChange={(e) => setControls({...controls,transactionLimit:e.target.value})}
              className="w-full border p-1 rounded"
              placeholder="in ether"
            />
          </div>
        </div>
      </div>
      <button
        type="button"
        className="mt-4 bg-success-btn py-1 px-2 rounded self-end text-white"
        onClick={handleFinish}
      >
        Finish
      </button>
    </>
  );
}

export default Controls;
