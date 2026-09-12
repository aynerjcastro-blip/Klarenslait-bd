# KlarensLait

KlarensLait es un proyecto de aula orientado al diseño de una base de datos para apoyar la trazabilidad y el control de calidad en procesos de producción láctea.

El proyecto parte del análisis de la operación de una planta procesadora de lácteos y busca estructurar la información generada desde la recepción de leche cruda hasta la obtención de productos terminados. Su propósito es facilitar el seguimiento de lotes, los controles de calidad, el almacenamiento y la consulta histórica de la información asociada a la producción.


## Descripción del proyecto

En una planta láctea se generan datos en diferentes momentos del proceso: recepción de materia prima, toma de muestras, análisis de calidad, almacenamiento, procesamiento, empaque y conservación del producto final.

Cuando esta información se administra de forma dispersa, manual o sin una estructura común, puede ser difícil responder preguntas importantes como:

- ¿De qué proveedor provino la leche usada en determinado producto?
- ¿Qué controles de calidad se realizaron a un lote?
- ¿Qué ocurrió durante el procesamiento de una producción?
- ¿Qué lote de producto se relaciona con una materia prima específica?
- ¿Qué información debe revisarse cuando se detecta una anomalía?

KlarensLait propone una solución basada en una base de datos relacional que permita organizar estos datos de forma consistente, consultable y trazable.


## Problema que aborda

El proyecto busca atender la necesidad de centralizar la información relacionada con la producción láctea y conservar la trazabilidad de los lotes a lo largo del proceso.

La ausencia de una estructura de datos adecuada puede generar dificultades para:

- Consultar el origen de una materia prima.
- Relacionar resultados de calidad con lotes específicos.
- Controlar el estado de aprobación o rechazo de la leche recibida.
- Identificar el recorrido de un lote durante producción.
- Registrar variables críticas del proceso.
- Hacer seguimiento a lotes de producto terminado.
- Preparar información para revisiones, auditorías o controles internos.
- Detectar y analizar desviaciones de calidad.


## Objetivo general

Diseñar una base de datos relacional para la gestión de trazabilidad y control de calidad en procesos de producción láctea, permitiendo registrar, relacionar y consultar información desde la recepción de leche cruda hasta el producto terminado.


## Objetivos específicos

- Analizar el proceso general de producción de productos lácteos.
- Identificar los actores, recursos, eventos y datos relevantes del dominio.
- Modelar conceptualmente las entidades y relaciones necesarias para la trazabilidad.
- Definir reglas de negocio asociadas al control de calidad y al manejo de lotes.
- Diseñar el modelo lógico y físico de la base de datos.
- Implementar la solución utilizando PostgreSQL.
- Elaborar consultas que permitan rastrear materias primas, lotes, análisis y controles de proceso.
- Documentar las decisiones tomadas durante el desarrollo del proyecto.



## Alcance inicial

La primera versión de KlarensLait se enfoca en los procesos informativos relacionados con:

- Registro de proveedores de leche.
- Recepción de leche cruda.
- Identificación y seguimiento de lotes.
- Toma de muestras.
- Registro de análisis de calidad.
- Almacenamiento de leche en silos.
- Registro de etapas y controles de producción.
- Generación de lotes de producto terminado.
- Consulta de trazabilidad entre materia prima y producto final.

El alcance puede ampliarse posteriormente con funcionalidades relacionadas con inventario, mantenimiento de maquinaria, gestión de usuarios, despachos, clientes, devoluciones, alertas, reportes avanzados e integración con sensores industriales.


## Fuera del alcance inicial

Para mantener el proyecto controlado, la primera versión no contempla de forma completa:

- Facturación y contabilidad.
- Nómina o gestión de talento humano.
- Gestión financiera de compras y ventas.
- Integración directa con sensores IoT o equipos industriales.
- Automatización física de maquinaria.
- Comercio electrónico.
- Aplicación móvil.
- Gestión completa de mantenimiento preventivo y correctivo.
- Gestión integral de distribución y transporte hacia clientes.

Estas funcionalidades pueden considerarse como trabajo futuro.



## Contexto de referencia

El análisis inicial se basa en información documental sobre los procesos de una planta láctea Klaren’s, ubicada en Valledupar. La fuente describe actividades como recepción de leche de proveedores de la región, control de calidad en laboratorio, almacenamiento en silos, tratamientos térmicos, empaque, almacenamiento y conservación de productos refrigerados.

La información documental se utiliza como punto de partida para el modelado. Los valores operativos, límites de calidad, tiempos, temperaturas, responsabilidades y procesos específicos deberán validarse antes de considerarse reglas definitivas del sistema.


## Enfoque de la solución

KlarensLait se plantea como una base de datos relacional que permita conservar una relación verificable entre:

Proveedor
    ↓
Recepción de leche
    ↓
Lote de leche cruda
    ↓
Muestras y análisis de calidad
    ↓
Almacenamiento y procesamiento
    ↓
Lote de producto terminado

Este enfoque permite consultar tanto la trazabilidad hacia atrás como la trazabilidad hacia adelante.

### Trazabilidad hacia atrás

Permite partir de un lote de producto terminado y conocer:

- La materia prima utilizada.
- Los proveedores relacionados.
- Los resultados de laboratorio.
- Los controles registrados durante el procesamiento.
- Los equipos o etapas involucradas.

### Trazabilidad hacia adelante

Permite partir de un lote de leche o de una recepción y conocer:

- En qué productos fue utilizado.
- Qué lotes de producto se relacionan con él.
- Qué controles se realizaron durante su transformación.
- Qué información debe revisarse ante un hallazgo de calidad.



## Tecnologías previstas

| Tecnología | Uso dentro del proyecto |
|---|---|
| PostgreSQL | Sistema gestor de base de datos relacional. |
| SQL | Creación de estructuras, restricciones, consultas y reportes. |
| Git | Control de versiones y trabajo colaborativo. |
| GitHub | Repositorio, documentación y seguimiento de cambios. |
| Draw.io | Elaboración de diagramas entidad–relación y otros modelos. |


---

## Estructura del repositorio

KlarensLait/
│
├── README.md
│
├── diagrams/
│   └── 
│
├── docs/
│   └── 
│
├── sql/
│   └── 
└── LICENSE

La estructura puede modificarse durante el desarrollo si el equipo identifica una forma más clara de organizar los artefactos.


## Documentación del proyecto
La documentación detallada se encuentra dentro de la carpeta `docs/`.


## Estado del proyecto

El proyecto se encuentra en etapa de análisis y modelado conceptual.

Actividades iniciales:

- [x] Identificación del contexto del proceso lácteo.
- [x] Revisión de información documental disponible.
- [x] Validación de requerimientos y supuestos del negocio.
- [x] Definición final de reglas de negocio.
- [x] Elaboración del modelo conceptual.
- [x] Construcción del diagrama entidad–relación.
- [ ] Diseño lógico de la base de datos.
- [ ] Implementación en PostgreSQL.
- [ ] Carga de datos de prueba.
- [ ] Desarrollo de consultas de trazabilidad.
- [ ] Pruebas y documentación final.

