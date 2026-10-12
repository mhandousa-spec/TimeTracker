/// Module: messaging / chat / presentation/ui/widgets/bubbles/forward_checkbox/forward_checkbox.dart
part of '../../../pages/chat_mobile_view.dart';

class FrowardCheckBox extends StatelessWidget {
  const FrowardCheckBox({
    super.key,
    required this.isMe,
    required this.index,
  });

  final bool isMe;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablett;

    return BlocBuilder<MessageCubit, MessageState>(
      builder: (context, state) {
        final cubit = context.read<MessageCubit>();

        // Extract forward checkboxes from state
        final forwardCheckBoxes = state is MessageLoaded
            ? state.forwardCheckBoxes
            : <bool>[];

        // Return empty widget if index is out of bounds
        if (index >= forwardCheckBoxes.length) {
          return const SizedBox.shrink();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox.adaptive(
              visualDensity: const VisualDensity(
                horizontal: -4.0,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: AppColors.secondaryPrimary,
                width: 1,
              ),
              activeColor: AppColors.secondaryPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.r),
              ),
              checkColor: AppColors.white,
              value: forwardCheckBoxes[index],
              onChanged: (value) {
                cubit.selectForwardMessage(
                  val: value ?? false,
                  messageIndex: index,
                );
              },
            ),
            if (!isMe) horizontalSpace(isTablet ? 32 : 8),
          ],
        );
      },
    );
  }
}