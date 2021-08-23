import React, { useState, useRef } from "react";
import Dashboard from "./components/Dashboard";
import { formatData } from "./utils";
import "./styles.css";

export default function App() {
	const [symbol, setsymbol] = useState("");
	const [price, setprice] = useState("0.00");
	const [pastData, setpastData] = useState({});
	const [priceAlarm, setpriceAlarm] = useState(null);
	const ws = useRef(null);

	let first = useRef(false);
	const url = "API_GATEWAY_ENDPOINT";
	const stocks = ['AAPL', 'GME', 'PFE', 'AMC', 'AMZN', 'MSFT', 'BA', 'NVDA', 'AMD', 'SPCE'];


	const handleSelect = async (e) => {
		let dataArr = [];
		setsymbol(e.target.value);
		await fetch(`${url}/shareprice?symbol=${e.target.value}`)
			.then((res) => res.json())
			.then((data) => {
				dataArr = data['message']['hData'];
				setprice(data['message']['price']);
				if (data['message']['price_alarm'] === "null")
					setpriceAlarm(null);
				else
					setpriceAlarm(data['message']['price_alarm'])
			})
			.catch((error) => {
				console.error('Error:', error);
			});
		
		let formattedData = formatData(dataArr);
		setpastData(formattedData);
	};

	return (
		<div className="container">
			{
				<select name="currency" defaultValue="" onChange={handleSelect}>
					<option value="" selected disabled hidden>Choose here</option>
					{stocks.map((symbol, i) => {
						return (
							<option key={i} value={symbol}>
								{symbol}
							</option>
						);
					})}
				</select>
			}
			<Dashboard symbol={symbol} price={price} priceAlarm={priceAlarm} data={pastData} />
		</div>
	);
}
