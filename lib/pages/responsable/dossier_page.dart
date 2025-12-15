import 'package:flutter/material.dart';

class ResponsableDossierPage extends StatefulWidget {
  final String dossierId;
  
  const ResponsableDossierPage({
    super.key,
    required this.dossierId,
  });

  @override
  State<ResponsableDossierPage> createState() => _ResponsableDossierPageState();
}

class _ResponsableDossierPageState extends State<ResponsableDossierPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _dossierData;
  final List<Map<String, dynamic>> _photos = [];
  
  @override
  void initState() {
    super.initState();
    _loadDossierData();
  }
  
  Future<void> _loadDossierData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample dossier data - in a real app, this would come from an API based on the ID
    final dossierData = {
      'id': widget.dossierId,
      'type': 'Sol',
      'clientName': 'Société Générale de Travaux',
      'clientReference': 'SGT-2023-0542',
      'dateReceived': '2023-04-12',
      'dateCollected': '2023-04-10',
      'status': 'En attente',
      'urgency': 'Normale',
      'technician': {
        'name': 'Mohammed Alami',
        'id': 'TECH-001',
        'contact': '+212 6 61 23 45 67',
      },
      'receptor': {
        'name': 'Nadia Benjelloun',
        'id': 'REC-003',
        'date': '2023-04-12',
        'observations': 'Échantillon reçu en bon état, conforme à la procédure.',
      },
      'location': {
        'project': 'Extension Route Nationale 1',
        'site': 'PK 42 + 500',
        'coordinates': '33.5731° N, 7.5898° W',
      },
      'description': 'Échantillon de sol prélevé à 1,5 mètres de profondeur au niveau d\'une zone d\'excavation pour fondation d\'un pont.',
      'possibleTests': [
        {'id': 'T-001', 'name': 'Analyse granulométrique', 'duration': '48h', 'price': 1200},
        {'id': 'T-002', 'name': 'Limites d\'Atterberg', 'duration': '24h', 'price': 900},
        {'id': 'T-003', 'name': 'Teneur en eau', 'duration': '24h', 'price': 400},
        {'id': 'T-004', 'name': 'Essai Proctor modifié', 'duration': '72h', 'price': 1800},
        {'id': 'T-005', 'name': 'CBR (California Bearing Ratio)', 'duration': '120h', 'price': 2200},
        {'id': 'T-006', 'name': 'Essai de compressibilité', 'duration': '168h', 'price': 3500},
      ],
      'attachments': [
        {'name': 'Formulaire de prélèvement', 'type': 'PDF', 'url': '/documents/formulaire_123.pdf'},
        {'name': 'Bon de commande client', 'type': 'PDF', 'url': '/documents/bc_sgt_0542.pdf'},
      ],
    };
    
    // Sample photos
    final photos = [
      {'url': 'assets/images/sample1.jpg', 'description': 'Échantillon lors du prélèvement'},
      {'url': 'assets/images/sample2.jpg', 'description': 'Zone de prélèvement'},
      {'url': 'assets/images/sample3.jpg', 'description': 'Conditionnement de l\'échantillon'},
    ];
    
    setState(() {
      _dossierData = dossierData;
      _photos.addAll(photos);
      _isLoading = false;
    });
  }
  
  void _navigateToAssignPage() {
    Navigator.pushNamed(context, '/responsable/assign/${widget.dossierId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dossier ${widget.dossierId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Impression du dossier demandée')),
              );
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _dossierData == null
              ? const Center(child: Text('Erreur lors du chargement du dossier'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dossier header with status and actions
                      _buildDossierHeader(),
                      
                      const Divider(height: 32),
                      
                      // Client and prelevement info
                      _buildSectionHeader('Informations Client et Prélèvement'),
                      _buildClientInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Location info
                      _buildSectionHeader('Localisation du Prélèvement'),
                      _buildLocationInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Sample description
                      _buildSectionHeader('Description de l\'Échantillon'),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_dossierData!['description']),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Photos
                      _buildSectionHeader('Photos'),
                      _buildPhotoGallery(),
                      
                      const SizedBox(height: 24),
                      
                      // Reception info
                      _buildSectionHeader('Informations de Réception'),
                      _buildReceptionInfo(),
                      
                      const SizedBox(height: 24),
                      
                      // Possible tests
                      _buildSectionHeader('Tests Possibles'),
                      _buildTestsTable(),
                      
                      const SizedBox(height: 24),
                      
                      // Attachments
                      _buildSectionHeader('Documents Attachés'),
                      _buildAttachmentsList(),
                      
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildDossierHeader() {
    final Color statusColor = {
      'En attente': Colors.orange,
      'Assigné': Colors.blue,
      'En test': Colors.green,
      'Terminé': Colors.purple,
    }[_dossierData!['status']] ?? Colors.grey;
    
    final Color urgencyColor = {
      'Normale': Colors.green,
      'Urgente': Colors.orange,
      'Très urgente': Colors.red,
    }[_dossierData!['urgency']] ?? Colors.grey;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ID and type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dossierData!['id'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${_dossierData!['type']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                
                // Status chip
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(_dossierData!['status']),
                      backgroundColor: statusColor.withOpacity(0.2),
                      labelStyle: TextStyle(color: statusColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Urgence: ${_dossierData!['urgency']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: urgencyColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  'Reçu le',
                  _dossierData!['dateReceived'],
                ),
                _buildInfoChip(
                  Icons.engineering,
                  'Technicien',
                  _dossierData!['technician']['name'],
                ),
                _buildInfoChip(
                  Icons.person,
                  'Réceptionniste',
                  _dossierData!['receptor']['name'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.grey.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildClientInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Client', _dossierData!['clientName']),
            const Divider(height: 24),
            _buildInfoRow('Référence Client', _dossierData!['clientReference']),
            const Divider(height: 24),
            _buildInfoRow('Date de Prélèvement', _dossierData!['dateCollected']),
            const Divider(height: 24),
            _buildInfoRow('Date de Réception', _dossierData!['dateReceived']),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLocationInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Projet', _dossierData!['location']['project']),
            const Divider(height: 24),
            _buildInfoRow('Site', _dossierData!['location']['site']),
            const Divider(height: 24),
            _buildInfoRow('Coordonnées', _dossierData!['location']['coordinates']),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReceptionInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Réceptionné par', _dossierData!['receptor']['name']),
            const Divider(height: 24),
            _buildInfoRow('ID Réceptionniste', _dossierData!['receptor']['id']),
            const Divider(height: 24),
            _buildInfoRow('Date de Réception', _dossierData!['receptor']['date']),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 120,
                  child: Text(
                    'Observations:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(_dossierData!['receptor']['observations']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
  
  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 180,
      child: _photos.isEmpty
          ? const Center(child: Text('Aucune photo disponible'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          photo['url'],
                          height: 120,
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 160,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported, size: 40),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 160,
                        child: Text(
                          photo['description'],
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildTestsTable() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Nom du Test')),
            DataColumn(label: Text('Durée Estimée')),
            DataColumn(label: Text('Prix (MAD)')),
          ],
          rows: _dossierData!['possibleTests']
              .map<DataRow>((test) => DataRow(
                    cells: [
                      DataCell(Text(test['id'])),
                      DataCell(Text(test['name'])),
                      DataCell(Text(test['duration'])),
                      DataCell(Text(test['price'].toString())),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
  
  Widget _buildAttachmentsList() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dossierData!['attachments'].length,
        itemBuilder: (context, index) {
          final attachment = _dossierData!['attachments'][index];
          return ListTile(
            leading: Icon(
              attachment['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.insert_drive_file,
              color: attachment['type'] == 'PDF' ? Colors.red : Colors.blue,
            ),
            title: Text(attachment['name']),
            subtitle: Text('Type: ${attachment['type']}'),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Téléchargement de ${attachment['name']}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _navigateToAssignPage,
            icon: const Icon(Icons.assignment),
            label: const Text('Assigner des Tests'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour à la Liste'),
          ),
        ),
      ],
    );
  }
} 