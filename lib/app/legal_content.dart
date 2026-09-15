/// RF-1 (spec 008): texto de políticas y términos de uso, mostrado en
/// `LegalScreen` y usado para generar el PDF descargable (RF-2).
/// Placeholder hasta que la Defensa Civil Colombiana entregue el texto
/// legal definitivo — cambiarlo pasa por code review, no por un panel
/// editable en runtime (ver plan.md).
const String kLegalDocumentTitle = 'Políticas y términos de uso';

const String kLegalDocumentBody = '''
Este es un texto provisional de políticas y términos de uso de la app
DCC-BOGOTA, sujeto a reemplazo por el texto definitivo que entregue la
Defensa Civil Colombiana, seccional Bogotá.

1. Uso de la app
Esta aplicación permite reportar emergencias, coordinar la respuesta de
voluntarios y funcionarios de la Defensa Civil, y acceder a contenido
informativo. El uso indebido de la función de reporte de emergencias
(reportes falsos) puede tener consecuencias legales.

2. Datos personales
Los datos capturados al reportar una emergencia o al registrarse como
voluntario se usan exclusivamente para la operación de la Defensa Civil
y, cuando corresponda, para actuar ante reportes falsos.

3. Responsabilidad
La información de prevención y recomendaciones ofrecida en la app es de
carácter general y no reemplaza la instrucción oficial de la Defensa
Civil ni de las autoridades competentes en una emergencia real.

4. Contacto
Para consultas sobre estas políticas, comunícate con la Defensa Civil
Colombiana, seccional Bogotá, por sus canales oficiales.
''';
