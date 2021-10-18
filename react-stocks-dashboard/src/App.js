import React, { useState, useRef } from "react";
import Dashboard from "./components/Dashboard";
import { formatData } from "./utils";
import { baseURL } from "./config/const";
import "./styles.css";

const STOCKS = ['AAPL', 'GME', 'PFE', 'AMC', 'AMZN', 'MSFT', 'BA', 'NVDA', 'AMD', 'SPCE'];

export default function App() {
	const [symbol, setsymbol] = useState("");
	const [price, setprice] = useState(0);
	const [pastData, setpastData] = useState({});
	const [priceAlarm, setpriceAlarm] = useState(null);

	const selectStock = async (e) => {
		setsymbol(e.target.value);
		try {
			const response = await fetch(`${baseURL}/shareprice?symbol=${e.target.value}`);
			if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);

			const { message: { price, price_alarm, hData } } = await response.json();
			setprice(+price);
			setpriceAlarm(+price_alarm || null)
			setpastData(formatData(hData));
		} catch (error) {
			console.log(error);
		}
	};

	return (
		<div className="container">
			{
				<select name="currency" defaultValue="" onChange={selectStock}>
					<option value="" disabled hidden>Choose here</option>
					{STOCKS.map((symbol, i) => {
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
