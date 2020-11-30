##-----------------------------------------------------------------------------
import numpy as np
##-----------------------------------------------------------------------------

def hexadec_creator(data_points, word_size):

	num_of_words = len(data_points)
	# word_size    = 12

	num_of_NUMBER_half_word = 4
	num_of_DATA_half_word   = 6
	num_of_CONTR_half_word  = 2

	header = ':02'

	with open('sin.hex', 'w') as file:
	    for i in range(num_of_words):
	        number = str(hex(i))
	        x_index = number.find('x')
	        number  = number[x_index + 1 : len(number)]
	        for j in range(num_of_NUMBER_half_word - len(number)):
	            number = '0' + number

	        data = str(hex(data_points[i]))
	        x_index = data.find('x')
	        data  = data[x_index + 1 : len(data)]
	        for j in range(num_of_DATA_half_word - len(data)):
	            data = '0' + data

	        message =   header + number + data

	        contr_summ = 0
	        
	        for j in range(1, len(message), 2):

	            contr_summ += int(message[j:j + 2], 16)

	        contr_summ -= 1
	        contr_summ = 255 - contr_summ
	        contr_summ = str(hex(contr_summ & 255))

	        x_index = contr_summ.find('x')
	        contr_summ  = contr_summ[x_index + 1 : len(contr_summ)]
	        for j in range(num_of_CONTR_half_word - len(contr_summ)):
	            contr_summ = '0' + contr_summ

	        file.write(message + contr_summ + '\n')

	    file.write(':00000001FF')

if __name__ == "__main__":

	hexadec_creator(1, 12)