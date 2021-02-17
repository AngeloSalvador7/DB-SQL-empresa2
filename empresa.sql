/*					ESTRUCTURACIÓN DE LA BASE DE DATOS.						 */

CREATE DATABASE IF NOT EXISTS empresa;
USE empresa;

Create table localidad(
cod_loc INT,
descripcion VARCHAR(50),
PRIMARY KEY (cod_loc)
);

Create table proyecto(
num_proy INT auto_increment,
nom_proy VARCHAR(50),
fecha_inicio DATE,
cod_loc INT not null,
PRIMARY KEY (num_proy),
FOREIGN KEY (cod_loc) REFERENCES localidad (cod_loc)
);

Create table departamento (
num_dep INT auto_increment,
nom_dep VARCHAR (50),
emp_superv INT not null,
PRIMARY KEY (num_dep)
);

Create table empleado(
num_emp INT auto_increment,
nombre_emp VARCHAR(50),
sueldo_emp DOUBLE not null,
num_dep INT not null,
PRIMARY KEY (num_emp),
FOREIGN KEY (num_dep) REFERENCES departamento (num_dep)
);

Create table trabaja_en(
num_emp INT,
num_proy INT,
horas TIME,
CONSTRAINT trabaja_en_pk PRIMARY KEY (num_emp, num_proy),
FOREIGN KEY (num_emp) REFERENCES empleado (num_emp),
FOREIGN KEY (num_proy) REFERENCES proyecto (num_proy)
);

ALTER TABLE departamento ADD FOREIGN KEY (emp_superv) REFERENCES empleado (num_emp);

/*						CONSULTAS						 */

/* - Seleccionar los nombres de proyectos donde haya empleados que ganen más de 100000. */

SELECT DISTINCT PR.nom_proy
FROM proyecto PR 
JOIN trabaja_en TRE 
ON PR.num_proy = TRE.num_proy
JOIN empleado EMP 
ON TRE.num_emp = EMP.num_emp
WHERE EMP.sueldo_emp > 100000.00;


/* - Seleccionar el nombre y número del empleado, nombre del departamento y sueldo del empleado que no trabaje en ningún proyecto. */

SELECT EMP.num_emp, EMP.nombre_emp, DEP.nom_dep, EMP.sueldo_emp
FROM empleado EMP 
JOIN departamento DEP 
ON EMP.num_dep = DEP.num_dep
WHERE EMP.num_emp NOT IN (SELECT num_emp
			  FROM trabaja_en);
 
 
 /* - Mostrar el nombre de empleados que trabajan en todos los proyectos. */
 
SELECT EMP.nombre_emp
FROM empleado EMP 
WHERE NOT EXISTS( SELECT 1
		  FROM proyecto PRY
		  WHERE NOT EXISTS( SELECT 1
				    FROM trabaja_en TRE
				    WHERE EMP.num_emp = TRE.num_emp AND PRY.num_proy = TRE.num_proy));
 
				   
 /* - Listar el nombre y sueldo de aquellos empleados que comienzan con la letra ‘D’, ganan entre $80000 y $120000 (ambos inclusive) 
      y trabajan en algún proyecto iniciado en el año 2018. */
				   
SELECT EMP.nombre_emp, EMP.sueldo_emp
FROM empleado EMP
WHERE EMP.nombre_emp LIKE 'D%'
AND EMP.sueldo_emp BETWEEN 80000.00 AND 120000.00
AND EXISTS( SELECT 1
	    FROM trabaja_en TRE 
	    JOIN proyecto PRY 
	    ON TRE.num_proy = PRY.num_proy
	    WHERE PRY.fecha_inicio BETWEEN '2018-01-01' AND '2018-12-31' AND TRE.num_emp = EMP.num_emp);
 
				   
 /* - Aumentar un 20% el sueldo de los empleados que trabajan en 2 proyectos o más. */
				   
UPDATE empleado EMP
SET EMP.sueldo_emp = EMP.sueldo_emp + (EMP.sueldo_emp * 0.2)
WHERE (SELECT COUNT(*)
       FROM trabaja_en TRE
       GROUP BY TRE.num_emp
       HAVING TRE.num_emp = EMP.num_emp) >= 2;
 
				   
 /* - Eliminar a todos los proyectos de la localidad de San Justo. */
				   
DELETE FROM proyecto PRY
WHERE PRY.cod_loc IN (SELECT LOC.cod_loc
		      FROM localidad LOC
		      WHERE LOC.descripcion LIKE 'San Justo');
				   

/* - Seleccionar los números y nombres de todos los empleados que trabajan en igual proyecto que el empleado Carlos. */
				   
SELECT DISTINCT EMP.num_emp, EMP.nombre_emp
FROM empleado EMP 
JOIN trabaja_en TRE 
ON EMP.num_emp = TRE.num_emp
WHERE EMP.nombre_emp NOT LIKE 'Carlos' AND TRE.num_proy IN (SELECT TRE2.num_proy
					 		    FROM empleado EMP2 
							    JOIN trabaja_en TRE2 
							    ON EMP2.num_emp = TRE2.num_emp
							    WHERE EMP2.nombre_emp LIKE 'Carlos');
				   

/* - Comienza a trabajar hoy en la empresa Sergio Alvarez con un sueldo de $70500. Su número de empleado será el 2148 
     y el número de departamento 24. Agregar el nuevo empleado a la base de datos. */
				   
INSERT INTO departamento(num_dep, nom_dep) 
VALUES (24, "Archivos");
INSERT INTO empleado(nombre_emp, sueldo_emp, num_dep) 
VALUES ("Sergio Alvarez", 70500.00, 24);

				   
/* - Indicar el importe promedio de proyectos, por cada localidad del mismo (descripción). Sólo mostrar aquellos donde el promedio sea superior a 200000. */
				   
SELECT LOC.descripcion, AVG(PRY.importe) AS promedio_importe
FROM proyecto PRY 
JOIN localidad LOC 
ON PRY.cod_loc = LOC.cod_loc
GROUP BY LOC.cod_loc , LOC.descripcion
HAVING promedio_importe > 200000;

