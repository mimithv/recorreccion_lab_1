.data
	mensaje: .asciiz "Ingrese 2 binarios de izq a der. Presione 2 si el binario está completo"
	entrada1: .asciiz "Binario1:"
	entrada2: .asciiz "Binario2:"
	mensajeError: .asciiz "Por favor ingrese 0, 1 o un 2 si ha finalizado"
	msg_resultado: .asciiz "Resultado: "
	newline: .asciiz "\n"
	largo: .asciiz "largo:"
	
.text

	main:
		# Instrucciones de entrada
		la $a0, mensaje
		jal imprimirMensaje
		
		la $a0, newline
		jal imprimirMensaje
		la $a0, newline
		jal imprimirMensaje
		
#===================================================================================================================================#

		pedirBinario1:
		# Mensaje de solicitud del primer binario
		la $a0, entrada1
		jal imprimirMensaje
		
		la $a0, newline
		jal imprimirMensaje
		
		# Pide el primer binario
		 la $s0, 0x100100a0 # Dirección primer binario
		 addi $t0, $zero, 4 # puntero
		 addi $t1, $zero, 0 # contador
		 addi $t3, $zero, 0 # limpieza $t3
		# Se solicita el binario bit a bit, se comprueba que el valor sea válido y se guarda en memoria
		loop1:
		 beq $t1, 8, salida1
		 jal pedirValor
		 jal bitApropiado1
		 beq $t3, 2, salida1
		 
		 sb $t3, 0($s0) # Carga en memoria
		 addi $t1, $t1, 1 # contador + 1
		 add $s0, $s0, $t0 # direccion + 4
		 j loop1
		
		salida1:
		 la $a0, newline
		 jal imprimirMensaje
		 
		 # Imprime la cantidad de bits del número binario
		 la $a0, largo
		 jal imprimirMensaje
		 
		 move $a0, $t1
		 jal imprimirEntero
		 
		 la $a0, newline
		 jal imprimirMensaje
		
#===================================================================================================================================#

		pedirBinario2:
		# Mensaje de solicitud del segundo binario
		la $a0, entrada2
		jal imprimirMensaje
		
		la $a0, newline
		jal imprimirMensaje
		
		# Pide el segundo binario
		 la $s1, 0x100100c0 # Dirección segundo binario
		 addi $t0, $zero, 4 # puntero
		 addi $t2, $zero, 0 # contador
		 addi $t3, $zero, 0 # limpieza $t3
		# Se solicita el binario bit a bit, se comprueba que el valor sea válido y se guarda en memoria
		loop2:
		 beq $t2, 8, salida2
		 jal pedirValor
		 jal bitApropiado2
		 beq $t3, 2, salida2
		 
		 sb $t3, 0($s1) # Carga en memoria
		 addi $t2, $t2, 1 # contador + 1
		 add $s1, $s1, $t0 # direccion + 4
		 j loop2
		 
		salida2:
		 la $a0, newline
		 jal imprimirMensaje
		 
		 # Imprime la cantidad de bits del número binario
		 la $a0, largo
		 jal imprimirMensaje
		 
		 move $a0, $t2
		 jal imprimirEntero
		 
		 la $a0, newline
		 jal imprimirMensaje

#===================================================================================================================================#

		# Compara la cantidad de bits de cada binario
		definirMenor:
		 blt $t1, $t2, primeroMenor
		 blt $t2, $t1, segundoMenor
		 beq $t1, $t2, iguales
		 
#===================================================================================================================================#
		
		# Adapta el primer binario al largo del segundo usando la direccion 0x10010100 para realizar el desplazamiento
		primeroMenor:
		 sub $t6, $t2, $t1 # obtiene la diferencia de cantidad de bits
		 addi $t4, $zero, 4 # puntero
		 mul $t6, $t6, $t4 # adapta la diferencia a la arquitectura (4 bits)
		 la $s0, 0x100100a0 # dirección del primer binario
		 la $s1, 0x10010100 # direccion auxiliar para realizar el desplazamiento de bits
		 add $s1, $s1, $t6 # realiza el desplazamiento
		 addi $t0, $zero, 0 # limpieza $t0
		 addi $t3, $zero, 0 # i=0
		 
		 # Mueve el binario desde 0x100100a0 hacia 0x10010100 realizando el desplazamiento
		 desplazamiento1.1:
		  beq $t3, $t1, limpiezaMemoria_1.1
		  
		  lb $t5, 0($s0)
		  sb $t5, 0($s1)
		  
		  add $s0, $s0, $t4 # direccion + 4
		  add $s1, $s1, $t4 # direccion + 4
		  addi $t3, $t3, 1 # i++
		  j desplazamiento1.1
		  
		# Limpia 0x100100a0
		limpiezaMemoria_1.1:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100a0
		cicloLimpieza1.1:
		 beq $t3, $t1, binarioListo1.1
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza1.1
		 
		# Devuelve el binario a su dirección original 0x100100a0 con el desplazamiento realizado
		binarioListo1.1:
		 addi $t3, $zero, 0 # i=0
		 addi $t4, $zero, 4 # puntero
		 la $s0, 0x100100a0
		 la $s1, 0x10010100
		cicloBinario1.1:
		 beq $t3, 8, limpiezaMemoria_1.2
		  
		 lb $t5, 0($s1)
		 sb $t5, 0($s0)
		  
		 add $s0, $s0, $t4 # direccion + 4
		 add $s1, $s1, $t4 # direccion + 4
		 addi $t3, $t3, 1 # i++
		 j cicloBinario1.1
		
		# Limpia 0x10010100
		limpiezaMemoria_1.2:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010100
		cicloLimpieza1.2:
		 beq $t3, 8, ajustar_binarios_1
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza1.2
		
		# Ubica ambos binarios ordenados en el data segment para ser operados
		ajustar_binarios_1:
		 addi $t8, $zero, 8 # cantidad de bloques de 4 bits disponibles
		 sub $t6, $t8, $t2 # se obtiene la cantidad de ceros que se requieren para rellenar a la izquierda
		 addi $t4, $zero, 4 # puntero
		 mul $t6, $t6, $t4 # cantidad de bits de diferencia
		 la $s0, 0x100100a0 # direccion binario 1
		 la $s1, 0x100100c0 # direccion binario 2
		 la $s2, 0x10010100 # direccion auxiliar 1 para realizar el desplazamiento de bits
		 la $s3, 0x10010120 # direccion auxiliar 2 para realizar el desplazamiento de bits
		 add $s2, $s2, $t6 # realiza el desplazamiento 1
		 add $s3, $s3, $t6 # realiza el desplazamiento 2
		 addi $t0, $zero, 0 # limpieza $t0
		 addi $t3, $zero, 0 # i=0
		 
		 # Mueve el binario 1 desde 0x100100a0 hacia 0x10010100 realizando el desplazamiento
		 # Mueve el binario 2 desde 0x100100c0 hacia 0x10010120 realizando el desplazamiento
		 desplazamiento1.2:
		  beq $t3, $t2, limpiezaMemoria_1.3
		  
		  lb $t5, 0($s0)
		  sb $t5, 0($s2)
		  
		  lb $t5, 0($s1)
		  sb $t5, 0($s3)
		  
		  add $s0, $s0, $t4 # direccion + 4
		  add $s1, $s1, $t4 # direccion + 4
		  add $s2, $s2, $t4 # direccion + 4
		  add $s3, $s3, $t4 # direccion + 4
		  addi $t3, $t3, 1 # i++
		  j desplazamiento1.2
		  
		# Limpia 0x100100a0
		limpiezaMemoria_1.3:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100a0
		cicloLimpieza1.3:
		 beq $t3, 8, limpiezaMemoria_1.4
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza1.3
		 
		# Limpia 0x100100c0
		limpiezaMemoria_1.4:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100c0
		cicloLimpieza1.4:
		 beq $t3, 8, binariosListos1
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza1.4
		 
		# Devuelve los binarios a sus direcciones originales con el desplazamiento realizado
		binariosListos1:
		 addi $t3, $zero, 0 # i=0
		 addi $t4, $zero, 4 # puntero
		 la $s0, 0x100100a0
		 la $s1, 0x100100c0
		 la $s2, 0x10010100
		 la $s3, 0x10010120
		cicloBinario1.2:
		 beq $t3, 8, limpiezaMemoria_1.5
		  
		 lb $t5, 0($s2)
		 sb $t5, 0($s0)
		 
		 lb $t5, 0($s3)
		 sb $t5, 0($s1)
		  
		 add $s0, $s0, $t4 # direccion + 4
		 add $s1, $s1, $t4 # direccion + 4
		 add $s2, $s2, $t4 # direccion + 4
		 add $s3, $s3, $t4 # direccion + 4
		 addi $t3, $t3, 1 # i++
		 j cicloBinario1.2
		
		# Limpia 0x10010100
		limpiezaMemoria_1.5:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010100
		cicloLimpieza1.5:
		 beq $t3, 8, limpiezaMemoria_1.6
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza1.5
		 
		# Limpia 0x10010120
		limpiezaMemoria_1.6:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010120
		cicloLimpieza1.6:
		 beq $t3, 8, finPrimeroMenor
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza1.6
		 
		finPrimeroMenor:
		 j operarXor
		 
#===================================================================================================================================#
 
 		# Adapta el segundo binario al largo del primero
		segundoMenor:
		 sub $t6, $t1, $t2 # obtiene la diferencia de cantidad de bits
		 addi $t4, $zero, 4 # puntero
		 mul $t6, $t6, $t4 # cantidad de bits de diferencia
		 la $s0, 0x100100c0 # dirección del segundo binario
		 la $s1, 0x10010100 # direccion auxiliar para realizar el desplazamiento de bits
		 add $s1, $s1, $t6 # realiza el desplazamiento
		 addi $t0, $zero, 0 # limpieza $t0
		 addi $t3, $zero, 0 # i=0
		 
		 # Mueve el binario desde 0x100100c0 hacia 0x10010100 realizando el desplazamiento
		 desplazamiento2.1:
		  beq $t3, $t2, limpiezaMemoria_2.1
		  
		  lb $t5, 0($s0)
		  sb $t5, 0($s1)
		  
		  add $s0, $s0, $t4 # direccion + 4
		  add $s1, $s1, $t4 # direccion + 4
		  addi $t3, $t3, 1 # i++
		  j desplazamiento2.1
		  
		# Limpia 0x100100c0
		limpiezaMemoria_2.1:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100c0
		cicloLimpieza2.1:
		 beq $t3, $t2, binarioListo2.1
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza2.1
		 
		# Devuelve el binario a su dirección original 0x100100c0 con el desplazamiento realizado
		binarioListo2.1:
		 addi $t3, $zero, 0 # i=0
		 addi $t4, $zero, 4 # puntero
		 la $s0, 0x100100c0
		 la $s1, 0x10010100
		cicloBinario2.1:
		 beq $t3, 8, limpiezaMemoria_2.2
		  
		 lb $t5, 0($s1)
		 sb $t5, 0($s0)
		  
		 add $s0, $s0, $t4 # direccion + 4
		 add $s1, $s1, $t4 # direccion + 4
		 addi $t3, $t3, 1 # i++
		 j cicloBinario2.1
		
		# Limpia 0x10010100
		limpiezaMemoria_2.2:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010100
		cicloLimpieza2.2:
		 beq $t3, 8, ajustar_binarios_2
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza2.2
		
		# Ubica ambos binarios ordenados en el data segment para ser operados
		ajustar_binarios_2:
		 addi $t8, $zero, 8 # cantidad de bloques de 4 bits disponibles
		 sub $t6, $t8, $t1 # se obtiene la cantidad de ceros que se requieren para rellenar a la izquierda
		 addi $t4, $zero, 4 # puntero
		 mul $t6, $t6, $t4 # cantidad de bits de diferencia
		 la $s0, 0x100100a0 # direccion binario 1
		 la $s1, 0x100100c0 # direccion binario 2
		 la $s2, 0x10010100 # direccion auxiliar 1 para realizar el desplazamiento de bits
		 la $s3, 0x10010120 # direccion auxiliar 2 para realizar el desplazamiento de bits
		 add $s2, $s2, $t6 # realiza el desplazamiento 1
		 add $s3, $s3, $t6 # realiza el desplazamiento 2
		 addi $t0, $zero, 0 # limpieza $t0
		 addi $t3, $zero, 0 # i=0
		 
		 # Mueve el binario 1 desde 0x100100a0 hacia 0x10010100 realizando el desplazamiento
		 # Mueve el binario 2 desde 0x100100c0 hacia 0x10010120 realizando el desplazamiento
		 desplazamiento2.2:
		  beq $t3, $t1, limpiezaMemoria_2.3
		  
		  lb $t5, 0($s0)
		  sb $t5, 0($s2)
		  
		  lb $t5, 0($s1)
		  sb $t5, 0($s3)
		  
		  add $s0, $s0, $t4 # direccion + 4
		  add $s1, $s1, $t4 # direccion + 4
		  add $s2, $s2, $t4 # direccion + 4
		  add $s3, $s3, $t4 # direccion + 4
		  addi $t3, $t3, 1 # i++
		  j desplazamiento2.2
		  
		# Limpia 0x100100a0
		limpiezaMemoria_2.3:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100a0
		cicloLimpieza2.3:
		 beq $t3, 8, limpiezaMemoria_2.4
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza2.3
		 
		# Limpia 0x100100c0
		limpiezaMemoria_2.4:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100c0
		cicloLimpieza2.4:
		 beq $t3, 8, binariosListos2
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza2.4
		 
		# Devuelve los binarios a sus direcciones originales con el desplazamiento realizado
		binariosListos2:
		 addi $t3, $zero, 0 # i=0
		 addi $t4, $zero, 4 # puntero
		 la $s0, 0x100100a0
		 la $s1, 0x100100c0
		 la $s2, 0x10010100
		 la $s3, 0x10010120
		cicloBinario2.2:
		 beq $t3, 8, limpiezaMemoria_2.5
		  
		 lb $t5, 0($s2)
		 sb $t5, 0($s0)
		 
		 lb $t5, 0($s3)
		 sb $t5, 0($s1)
		  
		 add $s0, $s0, $t4 # direccion + 4
		 add $s1, $s1, $t4 # direccion + 4
		 add $s2, $s2, $t4 # direccion + 4
		 add $s3, $s3, $t4 # direccion + 4
		 addi $t3, $t3, 1 # i++
		 j cicloBinario2.2
		
		# Limpia 0x10010100
		limpiezaMemoria_2.5:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010100
		cicloLimpieza2.5:
		 beq $t3, 8, limpiezaMemoria_2.6
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza2.5
		 
		# Limpia 0x10010120
		limpiezaMemoria_2.6:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010120
		cicloLimpieza2.6:
		 beq $t3, 8, finSegundoMenor
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza2.6
		 
		finSegundoMenor:
		 j operarXor

#===================================================================================================================================#
		
		# Ubica ambos binarios ordenados en el data segment para ser operados
		iguales:
		 addi $t8, $zero, 8 # cantidad de bloques de 4 bits disponibles
		 sub $t6, $t8, $t2 # se obtiene la cantidad de ceros que se requieren para rellenar a la izquierda
		 addi $t4, $zero, 4 # puntero
		 mul $t6, $t6, $t4 # cantidad de bits de diferencia
		 la $s0, 0x100100a0 # direccion binario 1
		 la $s1, 0x100100c0 # direccion binario 2
		 la $s2, 0x10010100 # direccion auxiliar 1 para realizar el desplazamiento de bits
		 la $s3, 0x10010120 # direccion auxiliar 2 para realizar el desplazamiento de bits
		 add $s2, $s2, $t6 # realiza el desplazamiento 1
		 add $s3, $s3, $t6 # realiza el desplazamiento 2
		 addi $t0, $zero, 0 # limpieza $t0
		 addi $t3, $zero, 0 # i=0
		 
		 # Mueve el binario 1 desde 0x100100a0 hacia 0x10010100 realizando el desplazamiento
		 # Mueve el binario 2 desde 0x100100c0 hacia 0x10010120 realizando el desplazamiento
		 desplazamiento3.1:
		  beq $t3, $t2, limpiezaMemoria_3.1
		  
		  lb $t5, 0($s0)
		  sb $t5, 0($s2)
		  
		  lb $t5, 0($s1)
		  sb $t5, 0($s3)
		  
		  add $s0, $s0, $t4 # direccion + 4
		  add $s1, $s1, $t4 # direccion + 4
		  add $s2, $s2, $t4 # direccion + 4
		  add $s3, $s3, $t4 # direccion + 4
		  addi $t3, $t3, 1 # i++
		  j desplazamiento3.1
		  
		# Limpia 0x100100a0
		limpiezaMemoria_3.1:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100a0
		cicloLimpieza3.1:
		 beq $t3, 8, limpiezaMemoria_3.2
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza3.1
		 
		# Limpia 0x100100c0
		limpiezaMemoria_3.2:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s0, 0x100100c0
		cicloLimpieza3.2:
		 beq $t3, 8, binariosListos3
		 sb $t0, 0($s0)
		 
		 addi $s0, $s0, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza3.2
		 
		# Devuelve los binarios a sus direcciones originales con el desplazamiento realizado
		binariosListos3:
		 addi $t3, $zero, 0 # i=0
		 addi $t4, $zero, 4 # puntero
		 la $s0, 0x100100a0
		 la $s1, 0x100100c0
		 la $s2, 0x10010100
		 la $s3, 0x10010120
		cicloBinario3.1:
		 beq $t3, 8, limpiezaMemoria_3.3
		  
		 lb $t5, 0($s2)
		 sb $t5, 0($s0)
		 
		 lb $t5, 0($s3)
		 sb $t5, 0($s1)
		  
		 add $s0, $s0, $t4 # direccion + 4
		 add $s1, $s1, $t4 # direccion + 4
		 add $s2, $s2, $t4 # direccion + 4
		 add $s3, $s3, $t4 # direccion + 4
		 addi $t3, $t3, 1 # i++
		 j cicloBinario3.1
		
		# Limpia 0x10010100
		limpiezaMemoria_3.3:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010100
		cicloLimpieza3.3:
		 beq $t3, 8, limpiezaMemoria_3.4
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza3.3
		 
		# Limpia 0x10010120
		limpiezaMemoria_3.4:
		 addi $t3, $zero, 0 # i=0
		 addi $t0, $zero, 0 # constante 0
		 la $s1, 0x10010120
		cicloLimpieza3.4:
		 beq $t3, 8, finIguales
		 sb $t0, 0($s1)
		 
		 addi $s1, $s1, 4 # direccion + 4 
		 addi $t3, $t3, 1 # iterador + 1
		 j cicloLimpieza3.4
		 
		finIguales:
		 j operarXor
		 
#===================================================================================================================================#

		operarXor:
		addi $t0, $zero, 0 # i=0
		addi $t1, $zero, 4 # puntero
		addi $t3, $zero, 0 # limpia $t3
		addi $t4, $zero, 0 # limpia $t4
		la $s0, 0x100100a0
		la $s1, 0x100100c0
		la $s2, 0x100100e0
		cicloXor:
		 beq $t0, 8, imprimirResultado
		 
		 lb $t3, 0($s0)
		 lb $t4, 0($s1)
		 xor $t5, $t3, $t4
		 sb $t5, 0($s2)
		 
		 add $s0, $s0, $t1 # direccion + 4
		 add $s1, $s1, $t1 # direccion + 4
		 add $s2, $s2, $t1 # direccion + 4
		 addi $t0, $t0, 1 # i++
		 j cicloXor
		
		imprimirResultado:
		 la $a0, msg_resultado
		 jal imprimirMensaje
		 addi $t0, $zero, 0 # i=0
		 addi $t1, $zero, 4 # puntero
		 la $s0, 0x100100e0
		cicloResultado:
		 beq $t0, 8, finPrograma
		 
		 lb $a0, 0($s0)
		 jal imprimirEntero
		 
		 add $s0, $s0, $t1 # direccion + 4
		 addi $t0, $t0, 1 # i++
		 j cicloResultado
		 
#===================================================================================================================================#

	# Procedimiento que imprime un mensaje
	# ENTRADA: valor de $a0
	# SALIDA: imprime el mensaje de $a0
	imprimirMensaje:
		li $v0, 4
		syscall
	 
	 	jr $ra
	 
	# Procedimiento que imprime un entero
	# ENTRADA: valor de $a0
	# SALIDA: imprime el entero de $a0
	imprimirEntero:
	 	li $v0, 1
		syscall
		
		jr $ra
	 
	# Procedimiento que pide un caracter ascii por consola
	# ENTRADA: no hay
	# SALIDA: Guarda el caracter en $t3
	pedirValor:
		li $v0, 12
		syscall
		
		move $t3, $v0
	
		jr $ra
	
 	# Procedimiento que comprueba si las entradas del primer binario son correctas
	# ENTRADA: valor ingresado por el usuario en $t3
	# SALIDA: Si $t3 es correcto continúa, caso contrario imprime "Error" y vuelve a solicitar el binario	
	bitApropiado1:
	
		beq $t3, 48, bitCorrecto0.1
		beq $t3, 49, bitCorrecto1.1
		beq $t3, 50, bitCorrecto2.1
		
		li $v0, 4
		la $a0, newline
		syscall
		
		#Imprime un mensaje de error
		li $v0, 4
		la $a0, mensajeError
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		
		j pedirBinario1
		
	bitCorrecto0.1:
	 	addi $t3, $zero, 0
		jr $ra
		
	bitCorrecto1.1:
	 	addi $t3, $zero, 1
		jr $ra
		
	bitCorrecto2.1:
	 	addi $t3, $zero, 2
		jr $ra
		
	# Procedimiento que comprueba si las entradas del segundo binario son correctas
	# ENTRADA: valor ingresado por el usuario en $t3
	# SALIDA: Si $t3 es correcto continúa, caso contrario imprime "Error" y vuelve a solicitar el binario
	bitApropiado2:
	
		beq $t3, 48, bitCorrecto0.2
		beq $t3, 49, bitCorrecto1.2
		beq $t3, 50, bitCorrecto2.2
		
		li $v0, 4
		la $a0, newline
		syscall
		
		#Imprime un mensaje de error
		li $v0, 4
		la $a0, mensajeError
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		
		j pedirBinario2
		
	bitCorrecto0.2:
	 	addi $t3, $zero, 0
		jr $ra
		
	bitCorrecto1.2:
	 	addi $t3, $zero, 1
		jr $ra
		
	bitCorrecto2.2:
	 	addi $t3, $zero, 2
		jr $ra
	
	# Le indica al sistema que el programa ha finalizado
	finPrograma:
		li $v0, 10
		syscall
