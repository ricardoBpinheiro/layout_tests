import 'package:flutter/material.dart';
import 'package:layout_tests/core/widgets/metric_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Total Usuários',
                  value: '1,234',
                  icon: Icons.people,
                  color: Color(0xFF3498DB),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Vendas do Mês',
                  value: 'R\$ 45,678',
                  icon: Icons.attach_money,
                  color: Color(0xFF2ECC71),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Produtos',
                  value: '567',
                  icon: Icons.inventory,
                  color: Color(0xFFE67E22),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  title: 'Pedidos',
                  value: '89',
                  icon: Icons.shopping_cart,
                  color: Color(0xFFE74C3C),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          Container(
            width: double.infinity,
            height: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendas dos Últimos 6 Meses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Text(
                      'Gráfico de Vendas\n(Aqui você pode integrar charts_flutter ou fl_chart)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
