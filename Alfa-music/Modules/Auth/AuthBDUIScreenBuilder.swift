import Foundation

@MainActor
final class AuthBDUIScreenBuilder {
    func makeScreen(state: AuthViewState) -> BDUIScreenDTO {
        BDUIScreenDTO(
            root: BDUINodeDTO(
                id: "auth_root",
                type: .scroll,
                content: .stack(
                    BDUIStackContentDTO(
                        spacing: .l,
                        padding: .m,
                        backgroundColor: .background,
                        cornerRadius: nil
                    )
                ),
                subviews: [
                    makeLandingCard(),
                    makeFormCard(
                        emailError: state.emailError,
                        passwordError: state.passwordError,
                        globalError: state.errorText
                    ),
                    BDUINodeDTO(
                        id: "auth_bottom_space",
                        type: .spacer,
                        content: .spacer(BDUISpacerContentDTO(height: 120)),
                        subviews: [],
                        action: nil,
                        isVisible: true
                    )
                ],
                action: nil,
                isVisible: true
            )
        )
    }

    private func makeLandingCard() -> BDUINodeDTO {
        BDUINodeDTO(
            id: "auth_brand_container",
            type: .container,
            content: .container(
                BDUIContainerContentDTO(
                    backgroundColor: .elevated,
                    padding: .m,
                    cornerRadius: .l
                )
            ),
            subviews: [
                BDUINodeDTO(
                    id: "auth_brand_stack",
                    type: .vStack,
                    content: .stack(
                        BDUIStackContentDTO(
                            spacing: .s,
                            padding: nil,
                            backgroundColor: nil,
                            cornerRadius: nil
                        )
                    ),
                    subviews: [
                        makeLabel(
                            id: "auth_title",
                            text: "Alfa Music",
                            style: .titleLarge,
                            color: .textPrimary,
                            alignment: "center"
                        ),
                        makeLabel(
                            id: "auth_subtitle",
                            text: "Войдите, чтобы продолжить",
                            style: .body,
                            color: .textSecondary,
                            alignment: "center"
                        )
                    ],
                    action: nil,
                    isVisible: true
                )
            ],
            action: nil,
            isVisible: true
        )
    }

    private func makeFormCard(
        emailError: String?,
        passwordError: String?,
        globalError: String?
    ) -> BDUINodeDTO {
        var subviews: [BDUINodeDTO] = []
        if let errorText = globalError, !errorText.isEmpty {
            subviews.append(
                makeLabel(
                    id: "auth_global_error",
                    text: errorText,
                    style: .errorBanner,
                    color: .error,
                    alignment: "left"
                )
            )
        }

        subviews.append(
            BDUINodeDTO(
                id: "auth_email_field",
                type: .textField,
                content: .textField(
                    BDUITextFieldContentDTO(
                        title: "Email",
                        placeholder: "Введите email",
                        text: nil,
                        errorMessage: emailError,
                        isSecure: false
                    )
                ),
                subviews: [],
                action: nil,
                isVisible: true
            )
        )

        subviews.append(
            BDUINodeDTO(
                id: "auth_password_field",
                type: .textField,
                content: .textField(
                    BDUITextFieldContentDTO(
                        title: "Пароль",
                        placeholder: "Введите пароль",
                        text: nil,
                        errorMessage: passwordError,
                        isSecure: true
                    )
                ),
                subviews: [],
                action: nil,
                isVisible: true
            )
        )

        subviews.append(
            BDUINodeDTO(
                id: "auth_login_button",
                type: .button,
                content: .button(
                    BDUIButtonContentDTO(
                        title: "Войти",
                        style: .primary,
                        isEnabled: true
                    )
                ),
                subviews: [],
                action: .callback(id: "auth_login_tap"),
                isVisible: true
            )
        )

        subviews.append(
            BDUINodeDTO(
                id: "auth_guest_button",
                type: .button,
                content: .button(
                    BDUIButtonContentDTO(
                        title: "Войти как гость",
                        style: .secondary,
                        isEnabled: true
                    )
                ),
                subviews: [],
                action: .callback(id: "auth_guest_tap"),
                isVisible: true
            )
        )

        return BDUINodeDTO(
            id: "auth_form_container",
            type: .container,
            content: .container(
                BDUIContainerContentDTO(
                    backgroundColor: .elevated,
                    padding: .m,
                    cornerRadius: .l
                )
            ),
            subviews: [
                BDUINodeDTO(
                    id: "auth_form_stack",
                    type: .vStack,
                    content: .stack(
                        BDUIStackContentDTO(
                            spacing: .m,
                            padding: nil,
                            backgroundColor: nil,
                            cornerRadius: nil
                        )
                    ),
                    subviews: subviews,
                    action: nil,
                    isVisible: true
                )
            ],
            action: nil,
            isVisible: true
        )
    }

    private func makeLabel(
        id: String,
        text: String,
        style: BDUITextStyleToken,
        color: BDUIColorToken,
        alignment: String
    ) -> BDUINodeDTO {
        BDUINodeDTO(
            id: id,
            type: .label,
            content: .label(
                BDUILabelContentDTO(
                    text: text,
                    textStyle: style,
                    color: color,
                    alignment: alignment,
                    numberOfLines: 0
                )
            ),
            subviews: [],
            action: nil,
            isVisible: true
        )
    }
}
