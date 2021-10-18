import React, { useState, useEffect } from "react";
import { Line } from "react-chartjs-2";
import Switch from "react-switch";
import { baseURL } from "../config/const";
import "./dashboard.css";

const REQUEST_OPTIONS = {
	method: 'POST',
	headers: { 'Content-Type': 'application/json' }
};
const LINE_OPTIONS = {
	tooltips: {
		intersect: false,
		mode: "index"
	},
	responsive: true,
	maintainAspectRatio: false
};

function Dashboard({symbol, price, priceAlarm, data}) {
	const [priceValue, setpriceValue] = useState("");
	const [checked, setChecked] = useState(false);
	const [inputValue, setinputValue] = useState("");
	const [validInput, setvalidInput] = useState(true);
	const [sumbitted, setSubmitted] = useState(false);

	useEffect(() => {
		setSubmitted(false);
		setvalidInput(true);
		setpriceValue(price);
		setinputValue(priceAlarm? priceAlarm : "");
		setChecked(priceAlarm? true : false)
	  }, [priceAlarm, price]);

	const onSwitchToggle = async (value) => {
		setChecked(!checked);
		if (!value) turnOffAlarm();
	}

	const turnOffAlarm = () => {
		setSubmitted(false);
		try {
			fetch(`${baseURL}/updatealarm/turnoff?symbol=${symbol}`, REQUEST_OPTIONS)
		} catch (error) {
			console.log(error);
		}
	}

	const submitNewPriceAlarm = async () => {
		if (isNaN(inputValue)) {
			setvalidInput(false);
			setSubmitted(false);
			return;
		} else {
			setvalidInput(true);
		}
		try {
			const response = await fetch(`${baseURL}/updatealarm?symbol=${symbol}&price=${inputValue}`, REQUEST_OPTIONS)
			if (response.ok) setSubmitted(true);
		} catch (error) {
			console.log(error);
		}
	}

	return (
		<div className="dashboard">
			<h2>{`Share price: $${priceValue}`}</h2>
			<div className="notificationPanel">
				<div className="labelAndSwitch">
					<span>Notify on price change</span>
					<Switch height={20} width={50} onChange={onSwitchToggle} checked={checked} />
				</div>
				{checked &&
					<>
					<div>
						<span>Price</span>
						<input type="text" value={inputValue} onChange={e => setinputValue(e.target.value)}/>
						{!validInput &&
							<label className="invalidLabel">Only numeric values are allowed</label>
						}
						{sumbitted && 
							<label className="submittedLabel">New price alarm set</label>
						}
					</div>
					<label className="infoLabel">Due to AWS SES limitations, only verified email addresses can receive notifications</label>
					<button onClick={submitNewPriceAlarm}>Submit</button>
					</>
				}
			</div>
			<div className="chart-container">
				<Line data={data} options={LINE_OPTIONS} />
			</div>
		</div>
	);
}

export default Dashboard;