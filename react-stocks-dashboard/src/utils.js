export const formatData = (data) => {
    let finalData = {
      labels: [],
      datasets: [
        {
          label: "Price",
          data: [],
          backgroundColor: "rgb(255, 99, 132, 0.8)",
          borderColor: "rgba(255, 99, 132, 0.2)",
          fill: false
        }
      ]
    };

    let dates = data.map((val) => {
      return val['date'];
    });

    let priceArr = data.map((val) => {
      return val['close'];
    });
  
    priceArr.reverse();
    dates.reverse();
    finalData.labels = dates;
    finalData.datasets[0].data = priceArr;

    return finalData;
  };
  