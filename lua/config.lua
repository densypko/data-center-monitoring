local module = {} 

-- Creo un array de wifis, para que se conecte al priemro que pille disponible 
module.SSID = {}  
module.SSID["MOVISTAR_7FD0"] = "lcdq9j7Ahc9TCMHcjqjj" --Carlos Segovia
module.SSID["MOVISTAR_5A77"] = "ZU57ARGHRUQR5n4fkLNB" --Carlos Madrid
module.SSID["Orange-0CEC"] = "lor_=kcorQypEcg41"      --Denys Mostoles

module.HOST = "test.mosquitto.org" 
module.PORT = 1883
 
module.ID = node.chipid()
-- module.ID = "ValorQueDesees" en caso de no querer que se publique el id de tu chip.

module.ENDPOINT = "nodemcu/"
-- El topic donde publicará será nodemcu/id_del_chip

return module    
