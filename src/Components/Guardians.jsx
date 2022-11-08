import React, { useEffect, useState } from "react";
import { toast } from "react-toastify";

function Guardians(props) {
  const [guardians, setGuardians] = useState([]);
  const [approvers, setApprovers] = useState([]);

  useEffect(() => {
    setGuardians(Array(3).fill().map(x=>({
      address: "",
    })));

    setApprovers(Array(3).fill().map(x=>({
      address: "",
    })));
  }, []);

  const handleAddGuardian = () => {
    let tempData = [...guardians];
    tempData.push({
      address: "",
    });
    setGuardians(tempData);
  };

  const handleAddApprover = () =>{
    let tempData = [...approvers];
    tempData.push({
      address: "",
    });
    setApprovers(tempData);
  }

  const handleRemoveGuardian = (position) => {
    let tempData = guardians.filter((x, i) => i !== position);
    setGuardians(tempData);
  };

  const handleRemoveApprover = (position) => {
    let tempData = approvers.filter((x, i) => i !== position);
    setApprovers(tempData);
  };

  const changeAddress = (value, index) => {
    let address = value.trim();
    setGuardians((prev) => {
      let newState = [...prev];
      newState[index]["address"] = address;
      return newState;
    });
  };

  const changeApproverAddress = (value, index) => {
    let address = value.trim();
    setApprovers((prev) => {
      let newState = [...prev];
      newState[index]["address"] = address;
      return newState;
    });
  };


  const changePassword = (value, index) => {
    let password = value.trim();
    setGuardians((prev) => {
      let newState = [...prev];
      newState[index]["password"] = password;
      return newState;
    });
  };

  const handleNext = () => {
    let isValidGuardians = guardians.every((x) => x.address && x.address.length === 42);
    let isValidApprovers = approvers.every(x => x.address && x.address.length === 42);

    if (isValidGuardians && isValidApprovers) {
    let duplicateGuardians = new Set(guardians.map(x => x.address)).size !== guardians.length;
    let duplicateApprovers = new Set(approvers.map(x => x.address)).size !== approvers.length;
      if(duplicateApprovers || duplicateGuardians){
        toast.error("Duplicate values are not allowed");
      }else{
        props.updateParent({guardians,approvers:approvers});
        props.setSteps(2);
      }
    } else {
      toast.error("Please provide valid values for all fields.");
    }
  };

  return (
    <>
      <h1 className="text-lg font-bold text-font-color self-start">
        Social Recovery
      </h1>
      <div className="w-full mt-6 px-6 grid grid-flow-row gap-2">
        {guardians.length &&
          guardians.map((guardian, index) => (
            <div key={`guardian-${index}`} className="grid md:grid-cols-5 lg:grid-cols-7 gap-4">
              <div className="font-medium">{"Guardian "+(index+1)}</div>
              <div className="col-span-3">
                <input
                  type="text"
                  value={guardian.address}
                  onChange={(e) => changeAddress(e.target.value, index)}
                  className="w-full border p-1 rounded"
                  placeholder="Guardian wallet address ..."
                  autoComplete="nope"
                />
              </div>
              <div>
                {index > 2 && (
                  <button
                    className="bg-cancel-btn p-1 rounded text-white"
                    onClick={() => handleRemoveGuardian(index)}
                  >
                    Delete
                  </button>
                )}
              </div>
            </div>
          ))}
      </div>
      <button
        type="button"
        className="mt-4 bg-success-btn p-2 rounded text-white self-end"
        onClick={handleAddGuardian}
      >
        Add Guardian
      </button>
      <h1 className="text-lg font-bold text-font-color self-start">
        MultiSig
      </h1>
      <div className="w-full mt-6 px-6 grid grid-flow-row gap-2">
        {approvers.length &&
          approvers.map((item, index) => (
            <div key={`guardian-${index}`} className="grid md:grid-cols-5 lg:grid-cols-7 gap-4">
              <div className="font-medium">{"Approver " + (index+1)}</div>
              <div className="col-span-3">
                <input
                  type="text"
                  value={item.address}
                  onChange={(e) => changeApproverAddress(e.target.value, index)}
                  className="w-full border p-1 rounded"
                  placeholder="Approver wallet address ..."
                  autoComplete="nope"
                />
              </div>
              
              <div>
                {index > 2 && (
                  <button
                    className="bg-cancel-btn p-1 rounded text-white"
                    onClick={() => handleRemoveApprover(index)}
                  >
                    Delete
                  </button>
                )}
              </div>
            </div>
          ))}
      </div>
      <button
        type="button"
        className="mt-4 bg-success-btn p-2 rounded text-white self-end"
        onClick={handleAddApprover}
      >
        Add Approver
      </button>
      <button
        type="button"
        className={`bg-success-btn mt-4 px-2 py-1 rounded text-white self-end`}
        onClick={handleNext}
      >
        Next
      </button>
    </>
  );
}

export default Guardians;
