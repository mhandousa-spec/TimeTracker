// ****************** FILE INFO ******************
// File Name: crm_quotes_mock_data.dart
// Purpose: Mock dataset for Deal Quotes matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';

abstract class CrmQuotesMockData {
  static List<CrmQuoteModel> getQuotes() {
    return <CrmQuoteModel>[
      const CrmQuoteModel(
        id: 'quote_1',
        no: 1,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.adjustment,
        approvalStatus: 'Approved',
        approvalStatusColor: Color(0xFF16A34A),
        validUntil: '7/12/2026',
        createdDate: '1/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_2',
        no: 2,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.pending,
        approvalStatus: 'Pending Approved',
        approvalStatusColor: Color(0xFFFF7A00),
        validUntil: '7/12/2026',
        createdDate: '2/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_3',
        no: 3,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.expired,
        approvalStatus: 'Pending Approved',
        approvalStatusColor: Color(0xFFFF7A00),
        validUntil: '7/12/2026',
        createdDate: '3/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_4',
        no: 4,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.reject,
        approvalStatus: 'Approved',
        approvalStatusColor: Color(0xFF16A34A),
        validUntil: '7/12/2026',
        createdDate: '4/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_5',
        no: 5,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.adjustment,
        approvalStatus: 'Pending Approved',
        approvalStatusColor: Color(0xFFFF7A00),
        validUntil: '7/12/2026',
        createdDate: '5/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_6',
        no: 6,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.approved,
        approvalStatus: 'Approved',
        approvalStatusColor: Color(0xFF16A34A),
        validUntil: '7/12/2026',
        createdDate: '6/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_7',
        no: 7,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.approved,
        approvalStatus: 'Approved',
        approvalStatusColor: Color(0xFF16A34A),
        validUntil: '7/12/2026',
        createdDate: '7/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
      const CrmQuoteModel(
        id: 'quote_8',
        no: 8,
        quoteNo: 'CT-2558',
        version: '1',
        clientStatus: CrmQuoteStatus.adjustment,
        approvalStatus: 'Pending Approved',
        approvalStatusColor: Color(0xFFFF7A00),
        validUntil: '7/12/2026',
        createdDate: '8/12/2026',
        total: 500.0,
        totalFormatted: '\$500',
      ),
    ];
  }
}
