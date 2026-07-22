import 'package:flutter/material.dart';

import 'package:flex_gym_inventory/src/data/dtos/social_proof_content.dart';
import 'package:flex_gym_inventory/src/models/social_proof_data.dart';
import 'package:flex_gym_inventory/src/widgets/displays/user_count.dart';
import 'package:flex_gym_inventory/src/widgets/displays/user_ratings.dart';

/// Displays social proof widgets side-by-side: a `UserCount` on the left
/// and `UserRatings` on the right, separated by 56 logical pixels.
class SocialProofDisplay extends StatelessWidget {
 	final SocialProofData? data;

 	const SocialProofDisplay({
 		Key? key,
 		this.data,
 	}) : super(key: key);

 	@override
 	Widget build(BuildContext context) {
 		return SizedBox(
 			width: 320,
 			child: Row(
 				mainAxisSize: MainAxisSize.min,
 				crossAxisAlignment: CrossAxisAlignment.center,
 				children: <Widget>[
 					UserCount(data: data ?? socialProofContent),
 					const SizedBox(width: 48),
 					const UserRatings(),
 				],
 			),
 		);
 	}
}

