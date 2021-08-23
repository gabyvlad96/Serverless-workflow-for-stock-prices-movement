import React, { useState, useEffect } from "react";
import { Line } from "react-chartjs-2";
import Switch from "react-switch";
import "./dashboard.css";

function Dashboard({symbol, price, priceAlarm, data}) {
	const [priceValue, setpriceValue] = useState("");
	const [checked, setChecked] = useState(false);
	const [inputValue, setinputValue] = useState("");
	const [validInput, setvalidInput] = useState(true);

	useEffect(() => {
		setpriceValue(price);
		setinputValue(priceAlarm? priceAlarm : "");
		setChecked(priceAlarm? true : false)
	  }, [priceAlarm, price]);

	const url = "API_GATEWAY_ENDPOINT";
	const opts = {
		tooltips: {
			intersect: false,
			mode: "index"
		},
		responsive: true,
		maintainAspectRatio: false
	};

	const onSwitchChange = async (e) => {
		setChecked(!checked);
		if (!e) {
			const requestOptions = {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
			};
			fetch(`${url}/updatealarm/turnoff?symbol=${symbol}`, requestOptions)
				.then(response => response.json())
				.then(data => {
					console.log(data)
				});
		}
	}

	const submitValue = async (e) => {
		if (isNaN(inputValue)) {
			setvalidInput(false);
			return
		} else {
			setvalidInput(true);
		}
		const requestOptions = {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
		};
		fetch(`${url}/updatealarm?symbol=${symbol}&price=${inputValue}`, requestOptions)
			.then(response => response.json())
			.then(data => {
				console.log(data)
			});
	}

	return (
		<div className="dashboard">
			<h2>{`Share price: $${priceValue}`}</h2>
			<div className="notificationPanel">
				<div className="labelAndSwitch">
					<span>Notify on price change</span>
					<Switch height={20} width={50} onChange={onSwitchChange} checked={checked} />
				</div>
				{checked &&
					<>
					<div>
						<span>Price</span>
						<input type="text" value={inputValue} onChange={e => setinputValue(e.target.value)}/>
						{!validInput &&
							<label className="invalidLabel">Only numeric values are allowed</label>
						}
					</div>
					<label className="infoLabel">Due to AWS SES limitations, only verified email addresses can receive notifications</label>
					<button onClick={submitValue}>Submit</button>
					</>
				}
			</div>
			<div className="chart-container">
				<Line data={data} options={opts} />
			</div>
		</div>
	);
}

export default Dashboard;