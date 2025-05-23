import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';
import 'package:subha_medicals/load_json_into_db/states_loader.dart';
import 'package:subha_medicals/load_json_into_db/taxcode_loader.dart';
import 'package:subha_medicals/screens/organisations/form_for_organisation_add_update.dart';
import 'package:subha_medicals/screens/organisations/listview_for_organisations.dart';

import 'package:subha_medicals/screens/states/state_list_all.dart';
import 'package:subha_medicals/screens/states/state_selector_page.dart';
import 'package:subha_medicals/screens/tax_codes/view_tax_code_filter.dart';
import 'package:subha_medicals/utils/share_db_utility.dart';

import 'package:subha_medicals/widgets/mainmenudrawer/build_card_section_drawer.dart';
import 'package:subha_medicals/widgets/mainmenudrawer/build_drawer_item.dart';
import 'package:subha_medicals/widgets/mainmenudrawer/build_sub_tiel_frdrawer.dart';
import 'package:subha_medicals/widgets/mainmenudrawer/card_for_subt_tiles.dart';

class MainDrawerMenu extends StatefulWidget {
  const MainDrawerMenu({super.key});

  @override
  State<MainDrawerMenu> createState() => _MainDrawerMenuState();
}

class _MainDrawerMenuState extends State<MainDrawerMenu> {
  bool _isLoading = false;
  int _loadedItems = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    setState(() {
      _isLoading = true;
      _loadedItems = 0;
      _totalItems = 0;
    });

    void onProgress(int current, int total) {
      setState(() {
        _loadedItems = current;
        _totalItems = total;
      });
    }

    try {
      await DBManager.database;
      print("Database initialized in MainDrawerMenu");

      // Pass the progress callback here
      await loadTaxCodesFromJson(onProgress: onProgress);

      // You can add similar for states loader if needed
      await loadStatesFromJson();
    } catch (e) {
      print("Initialization error: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _loadedItems = 0;
        _totalItems = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressPercent =
        (_totalItems > 0) ? (_loadedItems / _totalItems).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CleanStates'),
        backgroundColor: Colors.indigo,
        elevation: 4,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        elevation: 8,
        backgroundColor: Colors.grey[100],
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                const UserAccountsDrawerHeader(
                  accountName: Text('Welcome!'),
                  accountEmail: Text('user@example.com'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.indigo),
                  ),
                  decoration: BoxDecoration(color: Colors.indigo),
                ),
                const SizedBox(height: 8),
                BuildDrawerItem(
                  icon: Icons.home_outlined,
                  text: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                BuildSectionCard(
                  title: 'States',
                  icon: Icons.map_outlined,
                  children: [
                    BuildSubTile(
                      icon: Icons.touch_app,
                      text: 'State Selector',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StateSelectorPage(),
                          ),
                        );
                      },
                    ),
                    BuildSubTile(
                      icon: Icons.remove_red_eye_outlined,
                      text: 'View States',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Listviewallstate(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BuildSectionCard(
                  title: 'Organisations',
                  icon: Icons.people,
                  children: [
                    BuildSubTile(
                      icon: Icons.remove_red_eye,
                      text: 'view organisation  ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrganisationListScreen(),
                          ),
                        );
                      },
                    ),
                    BuildSubTile(
                      icon: Icons.add_outlined,
                      text: 'add customer  ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => OrganisationForm(isBillerMode: false),
                          ),
                        );
                      },
                    ),
                    BuildSubTile(
                      icon: Icons.add_business_sharp,
                      text: 'add biller  ',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => OrganisationForm(isBillerMode: true),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                BuildDrawerItem(
                  icon: Icons.info_outline,
                  text: 'Share DB',
                  onTap: () async {
                    try {
                      await ShareUtil.shareDatabase();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to share database: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                BuildDrawerItem(
                  icon: Icons.info_outline,
                  text: 'About',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'CleanStates',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.map, size: 40),
                      children: [
                        const Text('A simple app to manage Indian states.'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                BuildDrawerItem(
                  icon: Icons.info_outline,
                  text: 'New!TaxCodes with listview and filters',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaxCodeListWithFilterScreen(),
                      ),
                    );
                  },
                ),
                // Add padding at bottom so progress bar does not block content
                const SizedBox(height: 20),

                const SizedBox(height: 80),
              ],
            ),

            // Progress bar + percentage at bottom inside drawer during loading
            if (_isLoading)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.indigo.shade100,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.indigo.shade50,
                        color: Colors.indigo,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loading database: ${(progressPercent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.indigo.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Swipe from the left to open the menu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
